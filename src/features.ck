// =============================================================================
// features.ck — Audio feature extraction for Drive / Snap / Glare
//
// Two modes:
//   1. Procedural (deterministic) — sin/cos of time, for testing
//   2. Live audio — extracts from adc via FFT
//
// Public class. Reads from adc when live=true, otherwise synthetic.
// =============================================================================

public class Features
{
    // Output signals
    0.0 => float Drive;   // energy / loudness
    0.0 => float Snap;    // spectral centroid (normalized)
    0.0 => float Glare;   // spectral flux / transient

    // Mode
    0 => int live;  // 0 = procedural, 1 = live audio

    // --- Live audio analysis chain ---
    // (only connected when live mode is activated)
    adc => Gain g => FFT fft => blackhole;
    0.0 => g.gain;  // muted by default

    1024 => fft.size;
    Windowing.hamming(fft.size()) => fft.window;

    UAnaBlob blob;

    // Smoothing (simple EMA)
    0.0 => float raw_rms;
    0.0 => float raw_centroid;
    0.0 => float raw_flux;
    0.0 => float prev_flux;
    0.8 => float smooth;  // EMA coefficient (higher = smoother)

    // Enable live audio input
    fun void goLive()
    {
        1 => live;
        1.0 => g.gain;
    }

    // Update features for current frame
    fun void update(float t)
    {
        if( live ) updateLive();
        else       updateProcedural(t);
    }

    // Procedural: deterministic test signals
    fun void updateProcedural(float t)
    {
        Math.sin(t * 0.5)    => Drive;
        Math.cos(t * 0.25)   => Snap;
        (Drive * Snap)        => Glare;
    }

    // Live: extract from FFT
    fun void updateLive()
    {
        fft.upchuck() @=> blob;

        // RMS energy -> Drive (0 to ~1)
        0.0 => float sum_sq;
        for( 0 => int i; i < blob.fvals().size(); i++ )
        {
            blob.fvals()[i] * blob.fvals()[i] +=> sum_sq;
        }
        Math.sqrt(sum_sq / blob.fvals().size()) => float rms;
        smooth * raw_rms + (1.0 - smooth) * rms => raw_rms;
        Math.min(raw_rms * 4.0, 1.0) => Drive;  // scale to ~0-1

        // Spectral centroid -> Snap (-1 to 1)
        0.0 => float weighted_sum;
        0.0 => float mag_sum;
        for( 0 => int i; i < blob.fvals().size(); i++ )
        {
            blob.fvals()[i] * i +=> weighted_sum;
            blob.fvals()[i] +=> mag_sum;
        }
        0.0 => float centroid;
        if( mag_sum > 0.0001 )
            weighted_sum / mag_sum / blob.fvals().size() => centroid;
        smooth * raw_centroid + (1.0 - smooth) * centroid => raw_centroid;
        (raw_centroid * 2.0 - 1.0) => Snap;  // map to -1..1

        // Spectral flux -> Glare (-1 to 1)
        0.0 => float flux;
        for( 0 => int i; i < blob.fvals().size(); i++ )
        {
            blob.fvals()[i] - prev_flux +=> flux;
        }
        Math.fabs(flux) / blob.fvals().size() => flux;
        smooth * raw_flux + (1.0 - smooth) * flux => raw_flux;
        Math.min(raw_flux * 8.0, 1.0) => Glare;

        // Store for next frame
        if( blob.fvals().size() > 0 )
            blob.fvals()[0] => prev_flux;
    }
}
