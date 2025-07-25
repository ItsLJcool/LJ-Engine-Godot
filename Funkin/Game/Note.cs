using Godot;
using System;

public partial class Note : Node2D
{
    // Initalize Node Variables
    public AnimatedSprite2D Sprite;
    public Line2D Sustain;
    public Control ClipRect;
    public Sprite2D End;

    const string SustainsPath = "res://Assets/Notes/{0}/sustains/{1}-sustain.png";
    const string EndPath = "res://Assets/Notes/{0}/sustains/{1}-end.png";

    public Strum Strum;

    private float strumTime = 2000.0f;
    public float StrumTime
    {
        get { return strumTime; }
        set { strumTime = Math.Abs(value); }
    }
    private float susLength = 200.0f;
    public float SusLength
    {
        get { return susLength; }
        set { susLength = Math.Abs(value); }
    }

    public bool isSustainNote = true;

    public bool CanBeHit = false;
    public bool TooLate = false;
    public bool WasGoodHit = false;
    public bool Avoid = false;

    public Vector2 EndSize;

    private bool Initalized = false;
    public void Init(Strum strum, float time, float _susLength)
    {
        Strum = strum;
        StrumTime = time;
        SusLength = _susLength;

        if (Sprite.SpriteFrames.GetMeta("use_rotation").AsBool())
        {
            switch (Strum.Direction)
            {
                case 1:
                case 2:
                    Sprite.RotationDegrees -= 90.0f; break;
            }
        }

        Initalized = true;
        _Process(0);
        Visible = true;

        string DirName = strum.DirectionToString;
        Sprite.Play(DirName);
        Sustain.Texture = GD.Load<Texture2D>(string.Format(SustainsPath, "default", DirName));
        End.Texture = GD.Load<Texture2D>(string.Format(EndPath, "default", DirName));
    }

    public override void _Ready()
    {
        Visible = false;

        Sprite = GetNode<AnimatedSprite2D>("Sprite");
        Sustain = GetNode<Line2D>("Sustain");
        ClipRect = GetNode<Control>("Sustain/ClipRect");
        End = GetNode<Sprite2D>("Sustain/ClipRect/End");
        EndSize = End.Texture.GetSize();

        ClipRect.ClipContents = true;

        End.TextureChanged += () => { EndSize = End.Texture.GetSize(); };
    }

    public override void _Process(double delta)
    {
        if (!Initalized) return;

        base._Process(delta);
        float SongPosition = (float)Conductor.Instance.SongPosition;
        Vector2 pos = Vector2.Zero;

        pos.Y = (StrumTime - SongPosition) * (0.6f * (Strum.ScrollSpeed * 100 / 100));
        Position = pos;

        CanBeHit = (StrumTime + SusLength) > (SongPosition - (Strum.HitWindow * Strum.LatePressWindow)) && (StrumTime < (SongPosition + (Strum.HitWindow * Strum.EarlyPressWindow)));

        if ((StrumTime + SusLength) < (SongPosition - Strum.HitWindow) && !WasGoodHit) TooLate = true;

        if (Strum.StrumLine.IsPlayer && !Avoid && !WasGoodHit && StrumTime < SongPosition) GoodNoteHit();

        if (TooLate || (WasGoodHit && (StrumTime + SusLength) < SongPosition))
        {
            QueueFree();
            return;
        }

        if (isSustainNote) UpdateSustain(SongPosition);
    }

    public void UpdateSustain(float SongPosition)
    {
        int PointCount = Sustain.Points.Length;
        if (PointCount < 2) return;

        float LengthPog = 0.6f * Mathf.Round(Strum.ScrollSpeed * 100) / 100;

        float Y_VAL;
        Vector2 SusPos = Sustain.GlobalPosition;
        if (WasGoodHit)
        {
            Y_VAL = (SusLength + (StrumTime - SongPosition)) * LengthPog;
            SusPos.Y = Strum.GlobalPosition.Y;
        }
        else
        {
            Y_VAL = SusLength * LengthPog;
            SusPos.Y = GlobalPosition.Y;
        }
        
        Sustain.GlobalPosition = SusPos;

        Y_VAL -= EndSize.Y;
        Vector2[] Points = Sustain.Points;
        Points[0] = Vector2.Zero;
        Points[^1] = new Vector2(0, Math.Max(Y_VAL, 0));
        Sustain.Points = Points;

        Vector2 clipPos = ClipRect.Position;
        clipPos.X = -(EndSize.X * 0.5f);
        ClipRect.Position = clipPos;
        ClipRect.Size = new Vector2(EndSize.X, Y_VAL + EndSize.Y);

        End.Position = new Vector2(EndSize.X * 0.5f, Y_VAL);
    }

    public void GoodNoteHit()
    {
        WasGoodHit = true;
        Strum.HittingNote = true;

        if (!isSustainNote) QueueFree();
        else
        {
            var color = Sprite.SelfModulate;
            color.A = 0.0f;
            Sprite.SelfModulate = color;
        }
    }
}
