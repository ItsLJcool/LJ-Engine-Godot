using Godot;
using Godot.Collections;
using System;
using System.Collections;
using System.Linq;

public partial class PreloadedNote(float time, float susLength) : Node
{
    public float time = time;
    public float susLength = susLength;
}

public partial class TestStrum : Node2D
{
    private Node Conductor;
    public AnimatedSprite2D Sprite;
    public Node2D Notes;
    public TestStrumLine StrumLine; // TODO: implement StrumLine

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
    public string DirectionToString() { return DirectionStrings[direction % StrumsAmount]; }

    public override void _Ready()
    {
        Conductor = GetNode<Node>("/root/Conductor");
        NoteBlueprint = GD.Load<PackedScene>("res://TestNote.tscn");
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

    public void Init(TestStrumLine strumline, int dir)
    {
        StrumLine = strumline;
        Direction = dir;
        Scale = new Vector2(StrumLine.StrumScale, StrumLine.StrumScale);
        Sprite.Play(DirectionToString() + Static);
    }

    private Array<PreloadedNote> NotesToSpawn = [];
    public void PreloadNote(float time, float susLength)
    {
        NotesToSpawn.Add(new PreloadedNote(time, susLength));
    }

    public PackedScene NoteBlueprint;
    public void SpawnNote(float time, float susLength)
    {
        var NewNote = NoteBlueprint.Instantiate<TestNote>();
        Notes.AddChild(NewNote);
        NewNote.Init(this, time, susLength);
    }

    public override void _Process(double delta)
    {
        base._Process(delta);

        for (int i = 0; i < NotesToSpawn.Count; i++)
        {
            PreloadedNote Note = NotesToSpawn[i];
            if (Note.time - (float)Conductor.Get("song_position") > RenderLimit) continue;
            SpawnNote(Note.time, Note.susLength);
            NotesToSpawn.RemoveAt(i);
        }

        OnInput();
    }

    public void OnInput()
    {
        var input_name = string.Format(INPUT_NAME, DirectionToString());

        if (Input.IsActionJustPressed(input_name))
        {
            foreach (TestNote Note in Notes.GetChildren().Cast<TestNote>())
            { if (Note.CanBeHit && !Note.WasGoodHit) Note.GoodNoteHit(); }
        }

        if (Input.IsActionPressed(input_name))
        {
            string anim = string.Format("{0}{1}", DirectionToString(), (!HittingNote) ? Press : Confirm);
            if (Sprite.Animation != anim) Sprite.Play(anim);
        }

        if (Input.IsActionJustReleased(input_name))
        {
            Sprite.Play(DirectionToString() + Static);
            HittingNote = false;
        }
    }
}
