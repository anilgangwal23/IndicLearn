"""Shared Indic Parler-TTS loading and synthesis used by the devtools scripts."""

from pathlib import Path

import numpy as np
import torch
from parler_tts import ParlerTTSForConditionalGeneration
from transformers import AutoTokenizer

DEVTOOLS = Path(__file__).resolve().parent
MODEL_DIR = DEVTOOLS / "models" / "indic-parler-tts"
DEVICE = "cuda:0"


class TTSEngine:
    def __init__(self) -> None:
        if not torch.cuda.is_available():
            raise SystemExit("CUDA is not available. Check the torch install in setup.bat.")
        self.model = ParlerTTSForConditionalGeneration.from_pretrained(
            str(MODEL_DIR), torch_dtype=torch.float16
        ).to(DEVICE)
        self.tokenizer = AutoTokenizer.from_pretrained(str(MODEL_DIR))
        self.desc_tokenizer = AutoTokenizer.from_pretrained(
            self.model.text_encoder.config._name_or_path
        )
        self.sampling_rate = self.model.config.sampling_rate

    def synthesize(self, text: str, description: str) -> np.ndarray:
        desc = self.desc_tokenizer(description, return_tensors="pt")
        prompt = self.tokenizer(text, return_tensors="pt")
        with torch.no_grad():
            generation = self.model.generate(
                input_ids=desc.input_ids.to(DEVICE),
                attention_mask=desc.attention_mask.to(DEVICE),
                prompt_input_ids=prompt.input_ids.to(DEVICE),
                prompt_attention_mask=prompt.attention_mask.to(DEVICE),
            )
        audio = generation.float().cpu().numpy().reshape(-1)
        if audio.size == 0:
            raise RuntimeError(f"Model returned no audio for: {text!r}")
        return audio
