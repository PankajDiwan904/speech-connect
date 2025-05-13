import os
import wave
import json
from vosk import Model, KaldiRecognizer

# ---- Change this path depending on the language ----
model_path = "vosk_models/en"  # or vosk-english / vosk-telugu

# Load the model
if not os.path.exists(model_path):
    print("Model path not found!")
    exit(1)

model = Model(model_path)

# Open your audio file (must be WAV, mono, 16kHz)
wf = wave.open("converted.wav", "rb")

# Check audio format
if wf.getnchannels() != 1 or wf.getsampwidth() != 2 or wf.getframerate() != 16000:
    print("Please convert the audio to mono WAV with 16kHz sampling rate.")
    exit(1)

rec = KaldiRecognizer(model, wf.getframerate())
rec.SetWords(True)

# Run the recognizer
results = []
while True:
    data = wf.readframes(4000)
    if len(data) == 0:
        break
    if rec.AcceptWaveform(data):
        res = json.loads(rec.Result())
        results.append(res.get("text", ""))

# Final partial result
final_res = json.loads(rec.FinalResult())
results.append(final_res.get("text", ""))

# Print final output
final_text = " ".join([r for r in results if r])
print("🔊 Recognized Text:", final_text)
