using Godot;

public partial class Globals : Node {
    public static Globals Instance { get; private set; }

    public string JwtToken = "";
    public string Url = "";

    public override void _Ready() {
        if (Instance == null) {
            Instance = this;
        }
        else {
            QueueFree();
        }
    }
}