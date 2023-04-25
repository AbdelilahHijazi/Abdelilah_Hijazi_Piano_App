import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:piano/piano.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      color: const Color.fromARGB(255, 3, 182, 122),
      title: 'Abdelilah Hijazi Piano',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.notoSansTextTheme(textTheme),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _flutterMidi = FlutterMidi();

  void load(String asset) async {
    _flutterMidi.unmute();
    ByteData byte = await rootBundle.load(asset);
    _flutterMidi.prepare(sf2: byte, name: 'grand_piano.sf2');
  }

  final FocusNode _focusNode = FocusNode();

// Focus nodes need to be disposed.
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

// Handles the key events from the RawKeyboardListener and update the
// _message.
  void _handleKeyEvent(RawKeyEvent event) {
    onNotePositionTapped(event.logicalKey.keyId - 13);
  }

  @override
  void initState() {
    load('assets/sf/grand_piano.sf2');
    _focusNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Abdelilah Hijazi Piano",
          style: TextStyle(
              color: Colors.white,
              fontFamily: "Alkatra",
              fontSize: 30,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 3, 182, 122),
        shadowColor: const Color.fromARGB(255, 250, 250, 185),
        elevation: 30,
      ),
      backgroundColor: const Color.fromARGB(255, 145, 247, 199),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: _handleKeyEvent,
        child: ListView(
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Image.asset(
                "images/piano.gif",
                fit: BoxFit.contain,
              ),
            ),
            /* ClefImage(
              clef: Clef.Treble,
              clefColor: Colors.white,
              noteColor: Colors.white,
              noteImages: playedNotes
                  .map(
                    (it) => NoteImage(
                      notePosition: it,
                    ),
                  )
                  .toList(),
              noteRange: NoteRange.forClefs([
                Clef.Treble,
              ]),
              size: const Size(double.infinity, 130),
            ),
            ClefImage(
              clef: Clef.Bass,
              clefColor: Colors.white,
              noteColor: Colors.white,
              noteImages: playedNotes
                  .map(
                    (it) => NoteImage(
                      notePosition: it,
                    ),
                  )
                  .toList(),
              noteRange: NoteRange.forClefs([
                Clef.Bass,
              ]),
              size: const Size(double.infinity, 130),
            ), */
            SizedBox(
              height: 400,
              child: InteractivePiano(
                highlightedNotes: [NotePosition(note: Note.C, octave: 4)],
                highlightColor: const Color.fromARGB(255, 145, 247, 199),
                naturalColor: Colors.white,
                accidentalColor: Colors.black,
                keyWidth: 25,
                noteRange: NoteRange.forClefs([
                  Clef.Treble,
                  Clef.Alto,
                  Clef.Bass,
                ]),
                onNotePositionTapped: (pos) => onNotePositionTapped(pos.pitch),
              ),
            ),
            Center(
                child: SizedBox(
              height: 50,
              width: double.infinity,
              child: IconButton(
                iconSize: 40,
                icon: const Icon(
                  size: 40,
                  Icons.exit_to_app,
                  color: Colors.white,
                  weight: 30,
                ),
                onPressed: () {
                  // Perform exit action here
                  SystemNavigator.pop();
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  void onNotePositionTapped(int pitch) async {
    _flutterMidi.playMidiNote(midi: pitch);

    Future.delayed(const Duration(microseconds: 200)).then(
      (value) => setState(() {
        _flutterMidi.stopMidiNote(midi: pitch);
      }),
    );
  }
}
