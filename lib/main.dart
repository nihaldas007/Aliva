import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  // This prevents the "Black Screen" by keeping the native splash until we say so
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  runApp(const ElivaControlApp());
}

class ElivaControlApp extends StatelessWidget {
  const ElivaControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        primaryColor: Colors.cyanAccent,
      ),
      home: const SplashScreen(),
    );
  }
}

// ---------------------------------------------------------
// FULL RESTORED: Cyberpunk Glitch Splash Screen
// ---------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _glitchController;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    _glitchController = AnimationController(
      duration: const Duration(milliseconds: 60),
      vsync: this,
    )..repeat();

    // REDUCED: Changed to 1.5 seconds for speed, but kept the effect!
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ElivaDashboard()),
        );
      }
    });
  }

  @override
  void dispose() {
    _glitchController.dispose();
    super.dispose();
  }

  Widget _buildGlitchEffect(Widget child, {bool isText = false}) {
    return AnimatedBuilder(
      animation: _glitchController,
      builder: (context, _) {
        bool isGlitching = _random.nextDouble() < 0.60;
        if (!isGlitching) return child;

        double xOffset = (_random.nextDouble() - 0.5) * 18;
        double yOffset = (_random.nextDouble() - 0.5) * 10;
        double scale = 1.0 + (_random.nextDouble() - 0.5) * 0.15;
        double flickerOpacity = _random.nextDouble() < 0.2 ? 0.2 : 1.0;

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: flickerOpacity,
            child: Stack(
              children: [
                Transform.translate(
                  offset: Offset(xOffset + 6, yOffset),
                  child: Opacity(
                    opacity: 0.8,
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(Colors.redAccent, BlendMode.srcATop),
                      child: child,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(xOffset - 6, -yOffset),
                  child: Opacity(
                    opacity: 0.8,
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(Colors.cyanAccent, BlendMode.srcATop),
                      child: child,
                    ),
                  ),
                ),
                if (_random.nextDouble() < 0.4)
                  Transform.translate(
                    offset: Offset(-xOffset * 1.5, yOffset + 4),
                    child: Opacity(
                      opacity: 0.6,
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.mode(Colors.greenAccent, BlendMode.srcATop),
                        child: child,
                      ),
                    ),
                  ),
                Transform.translate(
                  offset: Offset(xOffset * 0.5, yOffset * 0.5),
                  child: child,
                ),
              ],
            ),
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    // REMOVE BLACK SCREEN: This removes the native splash the moment Flutter draws the first frame
    FlutterNativeSplash.remove();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _glitchController,
            builder: (context, _) {
              if (_random.nextDouble() < 0.05) {
                return Container(color: Colors.white.withOpacity(0.1));
              }
              return const SizedBox.shrink();
            },
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                _buildGlitchEffect(
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.cyanAccent, width: 2),
                      boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.2), blurRadius: 30, spreadRadius: 5)],
                      color: const Color(0xFF1D1E33),
                    ),
                    child: const Icon(Icons.memory, size: 70, color: Colors.cyanAccent),
                  ),
                ),
                const SizedBox(height: 40),
                _buildGlitchEffect(
                  Text("ALIVA CONTROL", style: GoogleFonts.orbitron(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2, shadows: [Shadow(color: Colors.cyanAccent.withOpacity(0.8), blurRadius: 15)])),
                  isText: true,
                ),
                const SizedBox(height: 15),
                AnimatedBuilder(
                  animation: _glitchController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _random.nextDouble() > 0.4 ? 1.0 : 0.0,
                      child: Text("SYSTEM BOOT SEQUENCE INITIATED...", style: GoogleFonts.mavenPro(fontSize: 10, color: Colors.cyanAccent.withOpacity(0.8), letterSpacing: 1)),
                    );
                  }
                ),
                const Spacer(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// [Include the ElivaDashboard and other classes below...]
// [Keep the rest of your ElivaDashboard and other classes below this...]
// ---------------------------------------------------------
// 2. Main Dashboard & Controller
// ---------------------------------------------------------
class ElivaDashboard extends StatefulWidget {
  const ElivaDashboard({super.key});

  @override
  _ElivaDashboardState createState() => _ElivaDashboardState();
}

class _ElivaDashboardState extends State<ElivaDashboard> {
  BluetoothConnection? connection;
  bool get isConnected => (connection?.isConnected ?? false);

  double headAngle = 90; 
  bool leftHandUp = false;
  bool rightHandUp = false;
  String? activeCommand; // Tracks which button is glowing

  Map<String, String> commands = {
    'Forward': 'F', 'Backward': 'B', 'Left': 'L', 'Right': 'R', 'Stop': 'S',
    'Head Left': 'HL', 'Head Center': 'HC', 'Head Right': 'HR',
    'Left Arm Up': 'LU', 'Left Arm Down': 'LD', 'Right Arm Up': 'RU', 'Right Arm Down': 'RD',
  };

  void _connectToDevice(BluetoothDevice device) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Connecting to ${device.name}..."), duration: const Duration(seconds: 1)));
    try {
      connection = await BluetoothConnection.toAddress(device.address);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Connected to ${device.name}!"), backgroundColor: Colors.green));

      connection!.input!.listen((data) {}).onDone(() {
        setState(() => connection = null);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Robot Disconnected"), backgroundColor: Colors.redAccent));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to connect."), backgroundColor: Colors.redAccent));
    }
  }

  void _sendCommand(String? cmd) async {
    if (cmd == null || cmd.isEmpty) return;
    if (isConnected) {
      connection!.output.add(utf8.encode("$cmd\n"));
      await connection!.output.allSent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text("ALIVA CONTROL", style: GoogleFonts.orbitron(fontSize: 18, letterSpacing: 1, fontWeight: FontWeight.bold)),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: () async {
              final updatedCommands = await Navigator.push(context, MaterialPageRoute(builder: (context) => CommandSettingsPage(currentCommands: commands)));
              if (updatedCommands != null) setState(() => commands = updatedCommands);
            },
          ),
          IconButton(
            icon: Icon(isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled, color: isConnected ? Colors.cyanAccent : Colors.redAccent),
            onPressed: () async {
              Map<Permission, PermissionStatus> statuses = await [Permission.bluetooth, Permission.bluetoothConnect, Permission.bluetoothScan, Permission.location].request();
              if ((statuses[Permission.bluetoothConnect]?.isGranted ?? false) || (statuses[Permission.bluetooth]?.isGranted ?? false)) {
                final BluetoothDevice? selectedDevice = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SelectDevicePage()));
                if (selectedDevice != null) _connectToDevice(selectedDevice);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bluetooth permissions are required."), backgroundColor: Colors.redAccent));
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(flex: 3, child: RobotVisualizer(headAngle: headAngle, leftHandUp: leftHandUp, rightHandUp: rightHandUp)),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(color: Color(0xFF1D1E33), borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHeadSection(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildDpad(), _buildArmSection()]),
                  const Divider(color: Colors.white10),
                  Text("ROBO TECH VALLEY", style: GoogleFonts.mavenPro(fontSize: 10, color: Colors.cyanAccent.withOpacity(0.5), letterSpacing: 1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadSection() {
    return Column(
      children: [
        Text("HEAD ROTATION", style: GoogleFonts.orbitron(fontSize: 12, color: Colors.cyanAccent)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _actionBtn("LEFT", () { setState(() => headAngle = 180); _sendCommand(commands['Head Left']); }),
            _actionBtn("CENTER", () { setState(() => headAngle = 90); _sendCommand(commands['Head Center']); }),
            _actionBtn("RIGHT", () { setState(() => headAngle = 0); _sendCommand(commands['Head Right']); }),
          ],
        ),
      ],
    );
  }

  Widget _buildArmSection() {
    return Column(
      children: [
        Text("ARM POS", style: GoogleFonts.orbitron(fontSize: 12, color: Colors.cyanAccent)),
        const SizedBox(height: 10),
        _armToggle("LEFT", leftHandUp, (v) { setState(() => leftHandUp = v); _sendCommand(v ? commands['Left Arm Up'] : commands['Left Arm Down']); }),
        _armToggle("RIGHT", rightHandUp, (v) { setState(() => rightHandUp = v); _sendCommand(v ? commands['Right Arm Up'] : commands['Right Arm Down']); }),
      ],
    );
  }

  Widget _buildDpad() {
    return Column(
      children: [
        _moveBtn(Icons.arrow_upward, commands['Forward']),
        Row(children: [_moveBtn(Icons.arrow_back, commands['Left']), const SizedBox(width: 45), _moveBtn(Icons.arrow_forward, commands['Right'])]),
        _moveBtn(Icons.arrow_downward, commands['Backward']),
      ],
    );
  }

  Widget _moveBtn(IconData icon, String? cmd) {
    bool isPressed = activeCommand == cmd;
    return GestureDetector(
      onTapDown: (_) { setState(() => activeCommand = cmd); _sendCommand(cmd); },
      onTapUp: (_) { setState(() => activeCommand = null); _sendCommand(commands['Stop']); },
      onTapCancel: () { setState(() => activeCommand = null); _sendCommand(commands['Stop']); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.all(4), padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isPressed ? Colors.cyanAccent.withOpacity(0.2) : const Color(0xFF0A0E21),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isPressed ? Colors.cyanAccent : Colors.cyanAccent.withOpacity(0.3), width: isPressed ? 2 : 1),
          boxShadow: [
            if (isPressed) BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 15, spreadRadius: 2)
            else if (isConnected) BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 10)
          ],
        ),
        child: Icon(icon, color: isPressed ? Colors.white : Colors.cyanAccent, size: isPressed ? 32 : 30),
      ),
    );
  }

  Widget _actionBtn(String label, VoidCallback tap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton(
        onPressed: tap,
        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.cyanAccent)),
        child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.white)),
      ),
    );
  }

  Widget _armToggle(String label, bool val, Function(bool) onChanged) {
    return Row(children: [Text(label, style: const TextStyle(fontSize: 10)), Switch(value: val, onChanged: onChanged, activeThumbColor: Colors.cyanAccent)]);
  }
}

// ---------------------------------------------------------
// 3. Command Settings Page
// ---------------------------------------------------------
class CommandSettingsPage extends StatefulWidget {
  final Map<String, String> currentCommands;
  const CommandSettingsPage({super.key, required this.currentCommands});
  @override
  _CommandSettingsPageState createState() => _CommandSettingsPageState();
}

class _CommandSettingsPageState extends State<CommandSettingsPage> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    widget.currentCommands.forEach((key, value) => _controllers[key] = TextEditingController(text: value));
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveSettings() {
    Map<String, String> updatedCommands = {};
    _controllers.forEach((key, c) => updatedCommands[key] = c.text.trim());
    Navigator.pop(context, updatedCommands);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CONFIG COMMANDS", style: GoogleFonts.orbitron()), backgroundColor: Colors.transparent, actions: [IconButton(icon: const Icon(Icons.check, color: Colors.cyanAccent), onPressed: _saveSettings)]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _controllers.entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: TextField(
            controller: entry.value,
            decoration: InputDecoration(labelText: entry.key, labelStyle: const TextStyle(color: Colors.white54), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.3)), borderRadius: BorderRadius.circular(10)), focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.cyanAccent), borderRadius: BorderRadius.circular(10)), filled: true, fillColor: const Color(0xFF1D1E33)),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _saveSettings, backgroundColor: Colors.cyanAccent, icon: const Icon(Icons.save, color: Colors.black), label: const Text("SAVE SETTINGS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
    );
  }
}

// ---------------------------------------------------------
// 4. Live Visual Robot Widget
// ---------------------------------------------------------
class RobotVisualizer extends StatelessWidget {
  final double headAngle; final bool leftHandUp; final bool rightHandUp;
  const RobotVisualizer({super.key, required this.headAngle, required this.leftHandUp, required this.rightHandUp});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center, clipBehavior: Clip.none,
        children: [
          Container(width: 90, height: 130, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24))),
          Positioned(
            top: -50,
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 90, end: headAngle), duration: const Duration(milliseconds: 300),
              builder: (context, double angle, child) => Transform.rotate(angle: (angle - 90) * (3.14 / 180), child: Container(width: 70, height: 50, decoration: BoxDecoration(color: Colors.cyanAccent, borderRadius: BorderRadius.circular(10)))),
            ),
          ),
          AnimatedPositioned(duration: const Duration(milliseconds: 300), left: -35, top: leftHandUp ? 0 : 40, child: Container(width: 25, height: 70, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10)))),
          AnimatedPositioned(duration: const Duration(milliseconds: 300), right: -35, top: rightHandUp ? 0 : 40, child: Container(width: 25, height: 70, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10)))),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// 5. Device Selection Page
// ---------------------------------------------------------
class SelectDevicePage extends StatefulWidget {
  const SelectDevicePage({super.key});
  @override
  _SelectDevicePageState createState() => _SelectDevicePageState();
}

class _SelectDevicePageState extends State<SelectDevicePage> {
  List<BluetoothDevice> devices = []; bool isScanning = true;

  @override
  void initState() {
    super.initState();
    FlutterBluetoothSerial.instance.getBondedDevices().then((list) => setState(() { devices = list; isScanning = false; })).catchError((e) => setState(() => isScanning = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PAIRED DEVICES", style: GoogleFonts.orbitron()), backgroundColor: Colors.transparent),
      body: isScanning 
        ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
        : devices.isEmpty
          ? Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text("No paired devices found.", textAlign: TextAlign.center, style: GoogleFonts.mavenPro(fontSize: 16, color: Colors.white70))))
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF1D1E33), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.cyanAccent.withOpacity(0.3))),
                child: ListTile(
                  leading: const Icon(Icons.memory, color: Colors.cyanAccent),
                  title: Text(devices[i].name ?? "Unknown Device", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(devices[i].address, style: const TextStyle(color: Colors.white54)),
                  onTap: () => Navigator.of(context).pop(devices[i]),
                  trailing: const Icon(Icons.link, color: Colors.cyanAccent),
                ),
              ),
            ),
    );
  }
}