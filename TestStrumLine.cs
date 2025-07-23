using Godot;
using System;
using System.Linq;

[Tool]
public partial class TestStrumLine : Node2D
{
    Node2D StrumsGroup;

    [Export]
    public bool IsPlayer = false;

    const int MAX_STRUMS = 4;

    [Export(PropertyHint.Range, "1,4,1")]
    public int StrumAmount = 4;

    public float StrumScale = 0.7f;

    private float _padding = 160f;
    [Export]
    public float Padding
    {
        get { return _padding; }
        set
        {
            _padding = value;
            RefreshStrums();
        }
    }
    private float _strumPosition = 0.25f;
    [Export]
    public float StrumPosition
    {
        get { return _strumPosition; }
        set
        {
            _strumPosition = Mathf.Clamp(value, 0f, 1f);
            RefreshStrums();
        }
    }

    public override void _Ready()
    {
        StrumsGroup = GetNode<Node2D>("Strums");

        StrumBlueprint = GD.Load<PackedScene>("res://TestStrum.tscn");

        RefreshStrums(true);
    }

    public PackedScene StrumBlueprint;
    public void RefreshStrums(bool reset = false)
    {
        if (StrumsGroup == null) return;
        if (reset)
        {
            foreach (var Strum in StrumsGroup.GetChildren()) Strum.QueueFree();
            for (int i = 0; i < StrumAmount; i++)
            {
                var NewStrum = StrumBlueprint.Instantiate<TestStrum>();
                NewStrum.Name = i.ToString();
                StrumsGroup.AddChild(NewStrum);
                NewStrum.Init(this, i);
            }
        }

        float lerp1 = Mathf.Lerp(0, 2, (StrumPosition >= 0.25f) ? 1 : 4 * StrumPosition);
        float lerp2 = Mathf.Lerp(0, 2, (StrumPosition <= 0.75f) ? 0 : 4 * (StrumPosition - 0.75f));

        float formula = ((0.5f - (lerp1 + lerp2)) * (Padding * StrumScale)) + (1280 * StrumPosition);

        StrumsGroup.Position = new Vector2(formula, 75);

        int j = 0; // lazy
        foreach (TestStrum Strum in StrumsGroup.GetChildren().Cast<TestStrum>())
        {
            Vector2 pos = Strum.Position;
            pos.X = (Padding * StrumScale * j);
            Strum.Position = pos;
            j++;
        }
    }
}
