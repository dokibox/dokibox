//
//  FFmpegDecoder.m
//  dokibox
//
//  Created by Miles Wu on 28/06/2015.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import "FFmpegDecoder.h"
#import "MusicController.h"
#import "libavformat/avio.h"
#import "libavformat/avformat.h"

int ffmpeg_readcallback(void *opaque, uint8_t *buf, int buf_size);
int ffmpeg_readcallback(void *opaque, uint8_t *buf, int buf_size) {
    FFmpegDecoder *ffmpegDecoder = (__bridge FFmpegDecoder *)opaque;
    MusicController *mc = [ffmpegDecoder musicController];

    NSData *data = [mc readInput:(unsigned long long)buf_size];
    int sizeread = (int)[data length]; // can be 0 for EOF
    memcpy(buf, [data bytes], sizeread);

    return sizeread;
}

int64_t ffmpeg_seekcallback(void *opaque, int64_t offset, int whence);

@implementation FFmpegDecoder

@synthesize musicController = _musicController;

-(id)initWithMusicController:(MusicController *)mc andExtension:(NSString *)extension {
    self = [super init];
    int retval;

    _musicController = mc;

    av_register_all();

    // Setup avformat data structures
    int avInputBufferSize = 4096; // avio can replace this with a bigger one if necessary!
    unsigned char *avInputBuffer = av_malloc(avInputBufferSize);
    _avioContext = avio_alloc_context(avInputBuffer, avInputBufferSize, 0, (__bridge void *)self, ffmpeg_readcallback, NULL, NULL);
    _avFormatContext = avformat_alloc_context();
    _avFormatContext->pb = _avioContext;

    // Open with avformat
    retval = avformat_open_input(&_avFormatContext, "", NULL, NULL);
    if(retval != 0) {
        DDLogError(@"avformat_open_input failed with %d", retval);
        return self;
    }

    // Choose first audio stream
    _streamIndex = -1;
    for(int i=0; i < _avFormatContext->nb_streams; i++) {
        if (_avFormatContext->streams[i]->codec->codec_type == AVMEDIA_TYPE_AUDIO) {
            _streamIndex = i;
            break;
        }
    }
    if(_streamIndex == -1) {
        DDLogError(@"No audio streams were found");
        return self;
    }

    // Get decoder
    _avCodecContext = _avFormatContext->streams[_streamIndex]->codec;
    AVCodec *avCodec = avcodec_find_decoder(_avCodecContext->codec_id);
    _avCodecContext->refcounted_frames = 0; // decoding buffer is managed by decoder
    retval = avcodec_open2(_avCodecContext, avCodec, NULL);
    if(retval != 0) {
        DDLogError(@"avcodec_open2 failed with %d", retval);
        return self;
    }

    // Create packet and frame. PACKET = demuxed data. FRAME = decoded data.
    int avPacketSize = avInputBufferSize; // avio can replace this with a bigger one if necessary!
    retval = av_new_packet(&_avPacket, avPacketSize);
    if(retval != 0) {
        DDLogError(@"av_new_packet failed with %d", retval);
        return self;
    }
    _avFrame = av_frame_alloc();

    // Need to decode one frame to get info on sample format
    _firstFrameDecodeInProgress = YES;
    [self decodeNextFrame];
    _firstFrameDecodeInProgress = NO;

    return self;
}

-(void)dealloc {
    // Cleanup and free FFmpeg data structures
    avcodec_close(_avCodecContext);
    av_frame_free(&_avFrame);
    av_free_packet(&_avPacket);
    avformat_free_context(_avFormatContext);
    av_free(_avioContext->buffer);
    av_free(_avioContext);

    // Also free _firstFrameDecodedData if it exists
    if(_firstFrameDecodedData && _firstFrameDecodedDataSize != -1) {
        free(_firstFrameDecodedData);
        _firstFrameDecodedData = 0;
        _firstFrameDecodedDataSize = -1;
    }
}

-(DecoderMetadata)decodeMetadata {
    _metadata.numberOfChannels = _avCodecContext->channels;
    _metadata.sampleRate = _avCodecContext->sample_rate;
    _metadata.totalSamples = _avFormatContext->streams[_streamIndex]->duration*_avFormatContext->streams[_streamIndex]->time_base.num*_metadata.sampleRate/_avFormatContext->streams[_streamIndex]->time_base.den;

    return _metadata;
}

-(DecodeStatus)decodeNextFrame {
    // First frame decode was done before we had a fifoBuffer to write to, so we can just recall it once and then clear it
    if(_firstFrameDecodedData && _firstFrameDecodedDataSize != -1) {
        [[_musicController fifoBuffer] write:_firstFrameDecodedData size:_firstFrameDecodedDataSize];
        free(_firstFrameDecodedData);
        _firstFrameDecodedData = 0;
        _firstFrameDecodedDataSize = -1;
        return DecoderSuccess;
    }

    int retval;

    // Demux
    retval = av_read_frame(_avFormatContext, &_avPacket);
    if(retval != 0) {
        DDLogError(@"av_read_frame failed with %d", retval);
        return DecoderEOF;
    }

    // Check which stream it is from
    if(_avPacket.stream_index != _streamIndex) {
        DDLogVerbose(@"Not our stream. Was looking for %d and got %d", _streamIndex, _avPacket.stream_index);
        return [self decodeNextFrame];
    }

    // Decode
    int got_frame;
    int bytes_consumed = avcodec_decode_audio4(_avCodecContext, _avFrame, &got_frame, &_avPacket);
    if(bytes_consumed < 0) {
        retval = bytes_consumed;
        DDLogError(@"avcodec_decode_audio4 failed with %d", retval);
        return DecoderEOF;
    }

    if(got_frame) {
        if(_firstFrameDecodeInProgress) { // Grab metadata during the first frame decode
            // Bits per sample
            if(_avCodecContext->sample_fmt == AV_SAMPLE_FMT_U8 || _avCodecContext->sample_fmt == AV_SAMPLE_FMT_U8P) {
                _metadata.bitsPerSample = 8;
                _metadata.format = DecoderFormatUnsigned;
            }
            else if(_avCodecContext->sample_fmt == AV_SAMPLE_FMT_S16 || _avCodecContext->sample_fmt == AV_SAMPLE_FMT_S16P) {
                _metadata.bitsPerSample = 16;
                _metadata.format = DecoderFormatSigned;
            }
            else if(_avCodecContext->sample_fmt == AV_SAMPLE_FMT_S32 || _avCodecContext->sample_fmt == AV_SAMPLE_FMT_S32P) {
                _metadata.bitsPerSample = 32;
                _metadata.format = DecoderFormatSigned;
            }
            else if(_avCodecContext->sample_fmt == AV_SAMPLE_FMT_FLT || _avCodecContext->sample_fmt == AV_SAMPLE_FMT_FLTP) {
                _metadata.bitsPerSample = 32;
                _metadata.format = DecoderFormatFloat;
            }
            else if(_avCodecContext->sample_fmt == AV_SAMPLE_FMT_DBL || _avCodecContext->sample_fmt == AV_SAMPLE_FMT_DBLP) {
                _metadata.bitsPerSample = 0;
                DDLogError(@"Audio samples are encoded with doubles. This is not supported.");
                return DecoderEOF;
            }

            // Interleaving
            if(_avCodecContext->sample_fmt == AV_SAMPLE_FMT_U8P || _avCodecContext->sample_fmt == AV_SAMPLE_FMT_S16P || _avCodecContext->sample_fmt == AV_SAMPLE_FMT_S32P || _avCodecContext->sample_fmt == AV_SAMPLE_FMT_FLTP || _avCodecContext->sample_fmt == AV_SAMPLE_FMT_DBLP)
               _needsInterleaving = YES;
            else
               _needsInterleaving = NO;
        }

        int data_size = av_samples_get_buffer_size(NULL, _avCodecContext->channels, _avFrame->nb_samples, _avCodecContext->sample_fmt, 1);

        void *tempBuffer = _avFrame->data[0];
        if(_needsInterleaving) { // Need to interleave channels L / R.
            tempBuffer = malloc(data_size);
            void *tempBuffer_needle = tempBuffer;
            int bps = _metadata.bitsPerSample/8;
            for(int i=0; i < _avFrame->nb_samples; i++) {
                memcpy(tempBuffer_needle, _avFrame->data[0] + i*bps, bps);
                tempBuffer_needle += bps;
                memcpy(tempBuffer_needle, _avFrame->data[1] + i*bps, bps);
                tempBuffer_needle += bps;
            }
        }

        if(_firstFrameDecodeInProgress == YES) {
            // First frame decode is done before we have a fifoBuffer to write to, so we store it for later
            // This was necessary to get sample info
            _firstFrameDecodedData = malloc(data_size);
            memcpy(_firstFrameDecodedData, tempBuffer, data_size);
            _firstFrameDecodedDataSize = data_size;
        }
        else {
            [[_musicController fifoBuffer] write:tempBuffer size:data_size];
        }

        // Free interleaving buffer if used
        if(_needsInterleaving) {
            free(tempBuffer);
        }

    }

    return DecoderSuccess;
}

-(void)seekToFrame:(unsigned long long)frame
{
}


@end
