#!/usr/bin/env python3
"""Generate 11 SFX for the Coffee Brewing mini-game.

Synthesises each sound procedurally using pure-Python wave/struct/math,
writes 16-bit mono WAV files at 44 100 Hz, then converts to OGG Vorbis
via ffmpeg (if available) or afconvert fallback.

Target: -3 dBFS peak across the set, normalised loudness.

Usage:
    python3 tools/generate_coffee_sfx.py            # WAV only when no encoder
    python3 tools/generate_coffee_sfx.py --wav-only  # force WAV-only output
"""

from __future__ import annotations
import math, struct, wave, os, subprocess, sys, random, hashlib

SAMPLE_RATE = 44100
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "godot", "audio", "minigames", "coffee")

# Peak target: -3 dBFS  →  10^(-3/20) ≈ 0.7079  →  amplitude 0.7079 * 32767 ≈ 23197
PEAK_AMP = 0.7079

# --------------------------------------------------------------------------- #
#  Audio primitives
# --------------------------------------------------------------------------- #

def sine(freq: float, t: float) -> float:
    return math.sin(2.0 * math.pi * freq * t)

def square(freq: float, t: float) -> float:
    return 1.0 if sine(freq, t) >= 0 else -1.0

def triangle(freq: float, t: float) -> float:
    phase = (t * freq) % 1.0
    return 4.0 * abs(phase - 0.5) - 1.0

def sawtooth(freq: float, t: float) -> float:
    phase = (t * freq) % 1.0
    return 2.0 * phase - 1.0

def noise(seed_val: float = 0.0) -> float:
    """Deterministic white noise from seed."""
    # Use hash for deterministic but noisy output
    h = hashlib.md5(struct.pack("d", seed_val)).digest()
    return (struct.unpack("H", h[:2])[0] / 32768.0) - 1.0

def envelope_adsr(t: float, attack: float, decay: float, sustain: float,
                  release: float, total: float) -> float:
    """Simple ADSR envelope, sustain is a level 0..1."""
    if t < 0:
        return 0.0
    if t < attack:
        return t / attack
    t2 = t - attack
    if t2 < decay:
        return 1.0 - (1.0 - sustain) * (t2 / decay)
    t3 = t - attack - decay
    hold = total - attack - decay - release
    if t3 < hold:
        return sustain
    t4 = t3 - hold
    if t4 < release:
        return sustain * (1.0 - t4 / release)
    return 0.0

def envelope_exp_decay(t: float, decay_rate: float) -> float:
    return math.exp(-decay_rate * t)

def envelope_linear(t: float, duration: float) -> float:
    if t >= duration:
        return 0.0
    return 1.0 - t / duration

def lowpass_simple(samples: list[float], cutoff_norm: float) -> list[float]:
    """Very simple one-pole lowpass filter. cutoff_norm in 0..1."""
    alpha = cutoff_norm
    out = [0.0] * len(samples)
    out[0] = samples[0] * alpha
    for i in range(1, len(samples)):
        out[i] = out[i-1] + alpha * (samples[i] - out[i-1])
    return out

def highpass_simple(samples: list[float], cutoff_norm: float) -> list[float]:
    """Simple one-pole highpass."""
    lp = lowpass_simple(samples, cutoff_norm)
    return [s - l for s, l in zip(samples, lp)]

def mix(a: list[float], b: list[float], mix_b: float = 0.5) -> list[float]:
    """Mix two buffers. mix_b is the level of b (a gets 1-mix_b)."""
    mix_a = 1.0 - mix_b
    length = max(len(a), len(b))
    result = [0.0] * length
    for i in range(length):
        va = a[i] if i < len(a) else 0.0
        vb = b[i] if i < len(b) else 0.0
        result[i] = va * mix_a + vb * mix_b
    return result

def add(a: list[float], b: list[float], gain_b: float = 1.0) -> list[float]:
    length = max(len(a), len(b))
    result = [0.0] * length
    for i in range(length):
        va = a[i] if i < len(a) else 0.0
        vb = b[i] if i < len(b) else 0.0
        result[i] = va + vb * gain_b
    return result

def normalize(samples: list[float], target_peak: float = PEAK_AMP) -> list[float]:
    peak = max(abs(s) for s in samples) if samples else 1.0
    if peak < 1e-10:
        return samples
    scale = target_peak / peak
    return [s * scale for s in samples]

def fade_in(samples: list[float], duration_s: float) -> list[float]:
    n = int(duration_s * SAMPLE_RATE)
    out = list(samples)
    for i in range(min(n, len(out))):
        out[i] *= i / n
    return out

def fade_out(samples: list[float], duration_s: float) -> list[float]:
    n = int(duration_s * SAMPLE_RATE)
    out = list(samples)
    start = max(0, len(out) - n)
    for i in range(start, len(out)):
        progress = (i - start) / n
        out[i] *= 1.0 - progress
    return out

def gen_samples(duration: float) -> int:
    return int(SAMPLE_RATE * duration)

# --------------------------------------------------------------------------- #
#  SFX generators — each returns a list[float] in -1..1 range
# --------------------------------------------------------------------------- #

def gen_coffee_note_hit() -> list[float]:
    """Soft wooden tap. ~80ms. Chiptune-flavored."""
    dur = 0.08
    n = gen_samples(dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        # Wood tap: filtered noise burst + low sine thud
        env = envelope_exp_decay(t, 60.0)
        # Pitched component — wood resonance around 800 Hz
        wood = sine(820, t) * 0.6 + sine(1640, t) * 0.2
        # Noise transient
        nz = noise(i * 0.73 + 42.0) * envelope_exp_decay(t, 120.0)
        samples.append((wood * env * 0.7 + nz * 0.3))
    return lowpass_simple(samples, 0.3)

def gen_coffee_note_perfect() -> list[float]:
    """Same tap with a high-pitched bell harmonic layered on. ~120ms."""
    dur = 0.12
    n = gen_samples(dur)
    # Base: same wood tap
    tap = gen_coffee_note_hit()
    # Extend to 120ms
    tap.extend([0.0] * (n - len(tap)))
    # Bell harmonic layer
    bell = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = envelope_exp_decay(t, 25.0)
        # Bell frequencies — high and shimmery
        b = (sine(2400, t) * 0.5 +
             sine(3600, t) * 0.3 +
             sine(4800, t) * 0.2)
        bell.append(b * env)
    return add(tap, bell, 0.5)

def gen_coffee_note_miss() -> list[float]:
    """Dull paper crumple. ~140ms."""
    dur = 0.14
    n = gen_samples(dur)
    samples = []
    rng = random.Random(12345)  # deterministic
    for i in range(n):
        t = i / SAMPLE_RATE
        env = envelope_adsr(t, 0.005, 0.03, 0.3, 0.06, dur)
        # Crumple = filtered noise bursts with varying amplitude
        nz = rng.uniform(-1, 1)
        # Add some crackling character
        crackle = 1.0 if rng.random() > 0.85 else 0.3
        samples.append(nz * env * crackle)
    # Heavy lowpass for "dull" quality
    return lowpass_simple(samples, 0.15)

def gen_coffee_pour_start() -> list[float]:
    """Espresso machine pump kicking in. ~200ms."""
    dur = 0.2
    n = gen_samples(dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        # Pump motor: low buzz ramping up
        env = min(1.0, t / 0.08)  # ramp up over 80ms
        env *= envelope_linear(t, dur + 0.05)
        # Motor buzz at ~60Hz with harmonics
        motor = (sine(55, t) * 0.4 +
                 sine(110, t) * 0.3 +
                 sine(165, t) * 0.15 +
                 sawtooth(55, t) * 0.1)
        # Pressure hiss building
        nz = noise(i * 1.13 + 7.0) * min(1.0, t / 0.12) * 0.2
        samples.append((motor * env + nz))
    result = lowpass_simple(samples, 0.25)
    return fade_out(result, 0.03)

def gen_coffee_pour_loop() -> list[float]:
    """1.0s seamless pour stream loop. Must loop cleanly."""
    dur = 1.0
    n = gen_samples(dur)
    samples = []
    rng = random.Random(54321)
    for i in range(n):
        t = i / SAMPLE_RATE
        # Liquid pour: filtered noise + subtle low resonance
        nz = rng.uniform(-1, 1)
        # Add some water-like modulation
        mod = 0.5 + 0.5 * sine(3.0, t)  # slow wobble
        # Low liquid resonance
        liquid = sine(180, t) * 0.15 * (0.8 + 0.2 * sine(1.7, t))
        samples.append(nz * 0.6 * mod + liquid)

    # Bandpass for water-like quality
    result = lowpass_simple(samples, 0.2)
    result = highpass_simple(result, 0.02)

    # Cross-fade the ends for seamless looping (50ms cross-fade)
    xfade = int(0.05 * SAMPLE_RATE)
    for i in range(xfade):
        blend = i / xfade
        # Blend the end into the start
        result[i] = result[i] * blend + result[n - xfade + i] * (1.0 - blend)
    # Trim to exactly 1.0s
    result = result[:n]
    return result

def gen_coffee_pour_release_good() -> list[float]:
    """Pour cuts off cleanly with a small ceramic clink. ~250ms."""
    dur = 0.25
    n = gen_samples(dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        # Brief water cutoff (noise tail dying fast)
        water_env = envelope_exp_decay(t, 40.0) * 0.3
        water = noise(i * 0.97 + 11.0) * water_env

        # Ceramic clink: high-frequency bell at ~50ms offset
        clink_t = t - 0.04
        if clink_t > 0:
            clink_env = envelope_exp_decay(clink_t, 35.0)
            clink = (sine(3200, clink_t) * 0.5 +
                     sine(4800, clink_t) * 0.3 +
                     sine(6400, clink_t) * 0.2) * clink_env * 0.6
        else:
            clink = 0.0

        samples.append(water + clink)
    return samples

def gen_espresso_hiss() -> list[float]:
    """Half-second high-pressure steam hiss."""
    dur = 0.5
    n = gen_samples(dur)
    samples = []
    rng = random.Random(99999)
    for i in range(n):
        t = i / SAMPLE_RATE
        # Steam: aggressive high-frequency noise
        env = envelope_adsr(t, 0.02, 0.05, 0.7, 0.15, dur)
        nz = rng.uniform(-1, 1)
        # Add some pressure variation
        pressure = 0.8 + 0.2 * sine(7.0, t)
        samples.append(nz * env * pressure)
    # Highpass for hissy quality
    result = highpass_simple(samples, 0.15)
    return result

def gen_coffee_success() -> list[float]:
    """Tiny chime + rubber stamp thud, layered. ~600ms."""
    dur = 0.6
    n = gen_samples(dur)

    # Chime: ascending notes
    chime = [0.0] * n
    notes = [880, 1100, 1320]  # Major triad-ish
    for j, freq in enumerate(notes):
        offset_s = j * 0.06
        for i in range(n):
            t = i / SAMPLE_RATE - offset_s
            if t < 0:
                continue
            env = envelope_exp_decay(t, 8.0)
            chime[i] += sine(freq, t) * env * 0.25
            chime[i] += sine(freq * 2, t) * env * 0.1  # overtone

    # Rubber stamp thud at ~100ms
    stamp = [0.0] * n
    for i in range(n):
        t = i / SAMPLE_RATE - 0.1
        if t < 0:
            continue
        env = envelope_exp_decay(t, 30.0)
        # Thud: low frequency impact + noise
        thud = sine(120, t) * 0.6 + sine(80, t) * 0.3
        nz = noise(i * 0.53 + 33.0) * envelope_exp_decay(t, 60.0) * 0.4
        stamp[i] = (thud + nz) * env

    result = add(chime, stamp, 0.7)
    return fade_out(result, 0.05)

def gen_coffee_failure() -> list[float]:
    """Sad sputter + offended single beep. ~700ms."""
    dur = 0.7
    n = gen_samples(dur)

    # Sputter: irregular noise bursts
    sputter = [0.0] * n
    rng = random.Random(77777)
    for i in range(n):
        t = i / SAMPLE_RATE
        if t > 0.4:
            break
        env = envelope_adsr(t, 0.01, 0.05, 0.5, 0.1, 0.4)
        # Irregular bursts
        burst = 1.0 if rng.random() > 0.6 else 0.2
        motor = sawtooth(45, t) * 0.3 + noise(i * 0.81 + 5.0) * 0.7
        sputter[i] = motor * env * burst

    sputter = lowpass_simple(sputter, 0.2)

    # Sad beep: descending tone starting at 400ms
    beep = [0.0] * n
    for i in range(n):
        t = i / SAMPLE_RATE - 0.35
        if t < 0 or t > 0.3:
            continue
        env = envelope_adsr(t, 0.01, 0.02, 0.8, 0.08, 0.3)
        # Descending frequency for "sad"
        freq = 600 - t * 200
        beep[i] = square(freq, t) * env * 0.3

    beep_lp = lowpass_simple(beep, 0.25)
    result = add(sputter, beep_lp, 0.6)
    return fade_out(result, 0.05)

def gen_coffee_machine_objects() -> list[float]:
    """Comic mechanical objection — descending bellows 'uh-oh'. ~900ms."""
    dur = 0.9
    n = gen_samples(dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = envelope_adsr(t, 0.03, 0.1, 0.6, 0.2, dur)

        # Descending bellows: sawtooth going from ~300 Hz to ~80 Hz
        freq = 300 - 220 * (t / dur)
        bellows = sawtooth(freq, t) * 0.4

        # Mechanical clatter
        clatter_env = envelope_exp_decay(t, 5.0)
        clatter = noise(i * 1.37 + 19.0) * 0.2 * clatter_env

        # Low "uh" resonance
        uh_freq = 200 - 100 * (t / dur)
        uh = sine(uh_freq, t) * 0.3

        # Sad wheeze at the end
        wheeze_t = t - 0.5
        wheeze = 0.0
        if wheeze_t > 0:
            wheeze_env = envelope_exp_decay(wheeze_t, 5.0)
            wheeze = noise(i * 2.1 + 51.0) * wheeze_env * 0.25

        samples.append((bellows + clatter + uh + wheeze) * env)

    result = lowpass_simple(samples, 0.2)
    return fade_out(result, 0.08)

def gen_stamp_caffeinated() -> list[float]:
    """Single decisive rubber stamp thud. ~150ms."""
    dur = 0.15
    n = gen_samples(dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        # Impact: fast attack, quick decay
        env = envelope_exp_decay(t, 35.0)
        # Low thud
        thud = sine(100, t) * 0.5 + sine(60, t) * 0.3
        # Transient snap
        snap = noise(i * 0.67 + 99.0) * envelope_exp_decay(t, 80.0) * 0.5
        # Slight "paper" resonance
        paper = sine(400, t) * envelope_exp_decay(t, 50.0) * 0.15
        samples.append((thud + snap + paper) * env)
    return lowpass_simple(samples, 0.35)

# --------------------------------------------------------------------------- #
#  File I/O
# --------------------------------------------------------------------------- #

def write_wav(path: str, samples: list[float]) -> None:
    """Write mono 16-bit WAV at 44100 Hz."""
    with wave.open(path, "w") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(SAMPLE_RATE)
        for s in samples:
            val = int(max(-32768, min(32767, s * 32767)))
            f.writeframes(struct.pack("<h", val))

def try_convert_to_ogg(wav_path: str, ogg_path: str) -> bool:
    """Try to convert WAV to OGG Vorbis using available tools."""
    # Try ffmpeg first
    for cmd in ["ffmpeg", "/usr/local/bin/ffmpeg", "/opt/homebrew/bin/ffmpeg"]:
        try:
            result = subprocess.run(
                [cmd, "-y", "-i", wav_path, "-ac", "1", "-ar", "44100",
                 "-c:a", "libvorbis", "-q:a", "4", ogg_path],
                capture_output=True, timeout=10
            )
            if result.returncode == 0 and os.path.getsize(ogg_path) > 0:
                return True
        except (FileNotFoundError, subprocess.TimeoutExpired):
            continue

    # Try oggenc
    for cmd in ["oggenc", "/usr/local/bin/oggenc", "/opt/homebrew/bin/oggenc"]:
        try:
            result = subprocess.run(
                [cmd, "-q", "4", "-o", ogg_path, wav_path],
                capture_output=True, timeout=10
            )
            if result.returncode == 0 and os.path.getsize(ogg_path) > 0:
                return True
        except (FileNotFoundError, subprocess.TimeoutExpired):
            continue

    # Try sox
    for cmd in ["sox", "/usr/local/bin/sox", "/opt/homebrew/bin/sox"]:
        try:
            result = subprocess.run(
                [cmd, wav_path, ogg_path],
                capture_output=True, timeout=10
            )
            if result.returncode == 0 and os.path.getsize(ogg_path) > 0:
                return True
        except (FileNotFoundError, subprocess.TimeoutExpired):
            continue

    return False

# --------------------------------------------------------------------------- #
#  Main
# --------------------------------------------------------------------------- #

SOUNDS: list[tuple[str, callable]] = [
    ("coffee_note_hit",            gen_coffee_note_hit),
    ("coffee_note_perfect",        gen_coffee_note_perfect),
    ("coffee_note_miss",           gen_coffee_note_miss),
    ("coffee_pour_start",          gen_coffee_pour_start),
    ("coffee_pour_loop",           gen_coffee_pour_loop),
    ("coffee_pour_release_good",   gen_coffee_pour_release_good),
    ("espresso_hiss",              gen_espresso_hiss),
    ("coffee_success",             gen_coffee_success),
    ("coffee_failure",             gen_coffee_failure),
    ("coffee_machine_objects",     gen_coffee_machine_objects),
    ("stamp_caffeinated",          gen_stamp_caffeinated),
]

def main() -> None:
    wav_only = "--wav-only" in sys.argv

    os.makedirs(OUT_DIR, exist_ok=True)

    # Generate all sounds
    all_samples: dict[str, list[float]] = {}
    for name, gen_func in SOUNDS:
        print(f"  Synthesising {name}...")
        samples = gen_func()
        samples = normalize(samples, PEAK_AMP)
        all_samples[name] = samples

    # Cross-normalise loudness: compute RMS of each and scale to a common target
    rms_values = {}
    for name, samples in all_samples.items():
        rms = math.sqrt(sum(s * s for s in samples) / len(samples)) if samples else 0
        rms_values[name] = rms

    # Target RMS: median of all RMS values (balanced approach)
    sorted_rms = sorted(rms_values.values())
    target_rms = sorted_rms[len(sorted_rms) // 2] if sorted_rms else 0.1

    for name, samples in all_samples.items():
        current_rms = rms_values[name]
        if current_rms > 1e-10:
            scale = target_rms / current_rms
            # Don't let scaling exceed the peak target
            peak = max(abs(s) for s in samples) * scale
            if peak > PEAK_AMP:
                scale *= PEAK_AMP / peak
            all_samples[name] = [s * scale for s in samples]

    # Write files
    ogg_converter_available = False
    for name, samples in all_samples.items():
        wav_path = os.path.join(OUT_DIR, f"{name}.wav")
        ogg_path = os.path.join(OUT_DIR, f"{name}.ogg")

        write_wav(wav_path, samples)
        dur_ms = len(samples) / SAMPLE_RATE * 1000
        wav_kb = os.path.getsize(wav_path) / 1024

        if not wav_only:
            if try_convert_to_ogg(wav_path, ogg_path):
                ogg_converter_available = True
                ogg_kb = os.path.getsize(ogg_path) / 1024
                os.remove(wav_path)  # Clean up WAV
                print(f"  ✓ {name}.ogg — {dur_ms:.0f}ms, {ogg_kb:.1f}KB")
            else:
                print(f"  ✓ {name}.wav — {dur_ms:.0f}ms, {wav_kb:.1f}KB (OGG conversion unavailable)")
        else:
            print(f"  ✓ {name}.wav — {dur_ms:.0f}ms, {wav_kb:.1f}KB")

    if not wav_only and not ogg_converter_available:
        print()
        print("=" * 64)
        print("  NOTE: No OGG Vorbis encoder found (ffmpeg/oggenc/sox).")
        print("  WAV files have been written. Convert with:")
        print()
        print("    brew install ffmpeg")
        print("    for f in godot/audio/minigames/coffee/*.wav; do")
        print('      ffmpeg -y -i "$f" -ac 1 -ar 44100 \\')
        print('        -c:a libvorbis -q:a 4 "${f%.wav}.ogg"')
        print("    done")
        print()
        print("  For coffee_pour_loop.ogg, also set loop=true in the")
        print("  .import file after Godot import.")
        print("=" * 64)

    print(f"\n  Done. {len(SOUNDS)} sounds in {OUT_DIR}")

if __name__ == "__main__":
    main()
