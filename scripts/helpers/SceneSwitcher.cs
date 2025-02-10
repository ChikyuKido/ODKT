using System;
using Godot;

public partial class SceneSwitcher : Button {
    [Export] private PackedScene _scenePath;

    public override void _Ready() {
        Connect("pressed", Callable.From(OnButtonPressed()));
    }

    private Action OnButtonPressed() {
        return () => {
            GetTree().ChangeSceneToPacked(_scenePath);
        };
    }
}