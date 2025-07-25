using Godot;
using System;

public partial class Conductor : Node
{
    public static Conductor Instance;
    // Audio Streams
    public AudioStreamPlayer Audio;

    // Variables
    private float bpm = 100;
    public float BPM
    {
        get { return bpm; }
        set
        {
            bpm = value;
            EmitSignal(SignalName.BPM_CHANGE, bpm);
            Crochet = (60 / bpm) * 1000;
            StepCrochet = Crochet / 4;
        }
    }
    public float Crochet = 0f;

    public float StepCrochet = 0f;

    public double SongPosition = 0;
    public double SongProgress
    {
        get
        {
            EmitSignal(SignalName.SONG_PROGRESS);
            return (Audio.Stream == null) ? 0 : Mathf.Clamp((SongPosition * 0.001) / Audio.Stream.GetLength(), 0, 1);
        }
    }

    public int BeatLength = 4;
    public int MeasureLength = 4;

    public int CurStep = 0;
    public int CurBeat = 0;
    public int CurMeasure = 0;

    public bool Paused = false;
    public bool SongStarted = false;

    // Signals
    [Signal]
    public delegate void STEP_HITEventHandler(int Step);
    [Signal]
    public delegate void BEAT_HITEventHandler(int Beat);
    [Signal]
    public delegate void MEASURE_HITEventHandler(int Measure);
    [Signal]
    public delegate void BPM_CHANGEEventHandler(float NewBPM);
    [Signal]
    public delegate void SONG_STARTEventHandler();
    [Signal]
    public delegate void SONG_PROGRESSEventHandler(); // Honestly Don't understand why this has its own signal for it :sob:

    public override void _Ready()
    {
        if (Instance != null)
        {
            QueueFree();
            return;
        }

        Instance = this;

        Audio = new AudioStreamPlayer();
        AddChild(Audio);
        
        Audio.Bus = "Music";
        Audio.Name = "SongPlayer";
        Audio.Finished += Finished;
    }

    private void Finished()
    {
        GD.Print("Song Finished");
        SongStarted = false;
        Paused = true;
        SongPosition = -5000;
    }

    public override void _Process(double delta)
    {
        if (!Paused && !SongStarted)
        {
            if (SongPosition >= 0) Intro(0);
            SongPosition += delta * 1000;
        }
        else if (!Paused && SongStarted) SongPosition = Audio.GetPlaybackPosition() * 1000;

        int OldStep = CurStep;

        CurStep = (int)Math.Floor(SongPosition / StepCrochet);
        CurBeat = (int)Math.Floor(CurStep / 4.0);
        CurMeasure = (int)Math.Floor(CurBeat / 4.0);

        if (OldStep != CurStep || CurStep == 1)
        {
            EmitSignal(SignalName.STEP_HIT, CurStep);
            if (CurStep % BeatLength == 0) EmitSignal(SignalName.BEAT_HIT, CurBeat);
            if (CurStep % MeasureLength == 0) EmitSignal(SignalName.MEASURE_HIT, CurMeasure);
        }

    }

    public void Load(AudioStream stream) { Audio.Stream = stream; }

    public void Intro(int Length)
    {
        if (Length > 0)
        {
            SongStarted = false;
            Paused = false;
            SongPosition = -(Crochet * Length);
        }
        else
        {
            Play();
            EmitSignal(SignalName.SONG_START);
        }
    }

    public void Play()
    {
        if (Audio.Stream == null) return;
        SongStarted = true;
        Paused = false;
        Audio.Play();
    }

    public void Pause()
    {
        Paused = true;
        if (Audio.Stream == null) return;
        Audio.StreamPaused = Paused;
    }

    public void Resume()
    {
        Paused = false;
        if (Audio.Stream == null) return;
        Audio.StreamPaused = Paused;
    }

    public void Reset()
    {
        SongStarted = false;
        SongPosition = 0;
        Audio.Stream = null;
    }

}
