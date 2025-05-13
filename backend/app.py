from flask import Flask, request, jsonify
from vosk import Model, KaldiRecognizer
from pydub import AudioSegment
import os
import wave
import json

app = Flask(__name__)

# Language to model mapping
MODEL_PATHS = {
    "en": "vosk_models/en",
    "hi": "vosk_models/hi",
    "te": "vosk_models/te"
}

# Load all models in advance
models = {lang: Model(path) for lang, path in MODEL_PATHS.items()}


@app.route("/stt", methods=["POST"])
def speech_to_text():
    if 'audio' not in request.files or 'lang' not in request.form:
        return jsonify({"error": "Missing audio or language"}), 400

    lang = request.form['lang']
    audio_file = request.files['audio']

    if lang not in models:
        return jsonify({"error": "Unsupported language"}), 400

    # Save uploaded audio temporarily
    audio_path = "temp.wav"
    audio_file.save(audio_path)

    # Convert to correct format
    sound = AudioSegment.from_file(audio_path)
    sound = sound.set_channels(1).set_frame_rate(16000)
    sound.export(audio_path, format="wav")

    # Transcribe with Vosk
    wf = wave.open(audio_path, "rb")
    rec = KaldiRecognizer(models[lang], wf.getframerate())

    result_text = ""
    while True:
        data = wf.readframes(4000)
        if len(data) == 0:
            break
        if rec.AcceptWaveform(data):
            result = json.loads(rec.Result())
            result_text += result.get("text", "") + " "

    final_result = json.loads(rec.FinalResult())
    result_text += final_result.get("text", "")

    return jsonify({"text": result_text.strip()})


if __name__ == "__main__":
    app.run(debug=True)
