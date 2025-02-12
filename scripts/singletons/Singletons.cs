using System.Net.WebSockets;
using Godot;


public partial class Singletons : Node {
    public static Singletons Instance { get; private set; }

    private ClientWebSocket websocket = new ClientWebSocket();

    public override void _Ready() {
        if (Instance == null) {
            Instance = this;
        }
        else {
            QueueFree();
        }
    }
}