using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public struct PreloadedNote(float time, float susLength)
{
    public float time = time;
    public float susLength = susLength;
}

public partial class Strum : Node2D
{
    public AnimatedSprite2D Sprite;
    public Node2D Notes;
    public StrumLine StrumLine;

    const string Press = "-press";
    const string Confirm = "-confirm";
    const string Static = "-static";

    public float EarlyPressWindow = 0.5f;
    public float LatePressWindow = 1f;
    public float HitWindow = 160f;

    public float RenderLimit = 1500f;

    public bool HittingNote = false;

    private float scrollSpeed = 1.5f;
    public float ScrollSpeed
    {
        get { return scrollSpeed; }
        set { scrollSpeed = Math.Abs(value); }
    }

    public int StrumsAmount = 4;

    private int direction = 0;
    public int Direction
    {
        get { return direction; }
        set { direction = value % StrumsAmount; }
    }
    public string[] DirectionStrings = ["left", "down", "up", "right"];
    const string INPUT_NAME = "NOTE_{0}";
    public string DirectionToString
    {
        get => DirectionStrings[direction % StrumsAmount];
    }

    public override void _Ready()
    {
        NoteBlueprint = GD.Load<PackedScene>("res://Funkin/Game/Note.tscn");
        Sprite = GetNode<AnimatedSprite2D>("Sprite");
        Notes = GetNode<Node2D>("Notes");

        PreloadNote(1000, 400);
        PreloadNote(2000, 400);
        PreloadNote(3000, 400);
        PreloadNote(4000, 400);

        PreloadNote(5000, 400);
        PreloadNote(6000, 400);
        PreloadNote(7000, 400);
        PreloadNote(8000, 400);
    }

    public void Init(StrumLine strumline, int dir)
    {
        StrumLine = strumline;
        Direction = dir;
        Scale = new Vector2(StrumLine.StrumScale, StrumLine.StrumScale);
        Sprite.Play(DirectionToString + Static);
    }

    private readonly List<float> NotesToSpawn = [];
    public void PreloadNote(float t, float l)
    {
        NotesToSpawn.Add(t);
        NotesToSpawn.Add(l);
    }

    public PackedScene NoteBlueprint;
    public void SpawnNote(float time, float susLength)
    {
        var NewNote = NoteBlueprint.Instantiate<Note>();
        Notes.AddChild(NewNote);
        NewNote.Init(this, time, susLength);
    }

    public override void _Process(double delta)
    {
        base._Process(delta);

        if (NotesToSpawn.Count >= 2)
        {
            float t = NotesToSpawn[0];
            float s = NotesToSpawn[1];
            if (t - (float)Conductor.Instance.SongPosition <= RenderLimit)
            {
                SpawnNote(t, s);
                NotesToSpawn.RemoveAt(0);
                NotesToSpawn.RemoveAt(0);
            }
        }

    }
    public override void _Input(InputEvent @event)
    {
        base._Input(@event);
        var input_name = string.Format(INPUT_NAME, DirectionToString);

        if (Input.IsActionPressed(input_name))
        {
            string anim = string.Format("{0}{1}", DirectionToString, (!HittingNote) ? Press : Confirm);
            if (Sprite.Animation != anim) Sprite.Play(anim);
        }

        if (@event.IsActionPressed(input_name))
        {
            foreach (Note Note in Notes.GetChildren().Select(Note => Note as Note).Where(Note => Note.CanBeHit && !Note.WasGoodHit))
            {
                Note.GoodNoteHit();
            }
        }

        if (@event.IsActionReleased(input_name))
        {
            Sprite.Play(DirectionToString + Static);
            HittingNote = false;
        }
    }
}