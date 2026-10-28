// AudioWorklet processor for the Mushaf+ voice model: forwards the microphone
// input to the main thread as mono Float32 chunks of 2048 samples (128 ms at
// 16 kHz). The audio context is opened at 16 kHz where the browser allows it;
// otherwise lib/data/speech_engine_whisper_web.dart resamples.
class MushafCaptureProcessor extends AudioWorkletProcessor {
  constructor() {
    super();
    this.size = 2048;
    this.buf = new Float32Array(this.size);
    this.n = 0;
  }

  process(inputs) {
    const channel = inputs[0] && inputs[0][0];
    if (!channel) return true;
    for (let i = 0; i < channel.length; i++) {
      this.buf[this.n++] = channel[i];
      if (this.n === this.size) {
        this.port.postMessage(this.buf, [this.buf.buffer]);
        this.buf = new Float32Array(this.size);
        this.n = 0;
      }
    }
    return true;
  }
}

registerProcessor('mushaf-capture', MushafCaptureProcessor);
