//: This demonstrates a simple MIDI system that uses AVMIDIPlayer. Currently it's very primitive and not all of the features have been tested. As I use MIDI and improve it, I will try to keep this playground updated.
//: Currently, notes, chords, drums, and program change are supported.
import Cocoa
import AVFoundation
import AudioUnit
import AudioToolbox
import CoreServices

public typealias Byte = UInt8

/// Ad-hoc namespace that should not be instantiated. Contains static functions for creating MIDI data.
/// Documentation assumes you are familiar with the MIDI spec. If you are not, you can find a reference at [this link](http://www.personal.kent.edu/~sbirch/Music_Production/MP-II/MIDI/an_introduction_to_midi_contents.htm).
/// Preferred usage: create an array of bytes by concatenating events such as MIDI.note( and MIDI.chord(, then use MIDI.file( passing this array as "contents" to create a valid array of bytes which can be fed to Data(bytes and then to an AVMIDIPlayer. MIDI.track and MIDI.headerChunk are discouraged use because they do not generate valid MIDI files on their own.
public struct MIDI {

    /// Using the MIDI table from [this link](https://www.midi.org/specifications/item/gm-level-1-sound-set)
    public static let AcousticGrandPiano: Byte = 1
    public static let BrightAcousticPiano: Byte = 2
    public static let ElectricGrandPiano: Byte = 3
    public static let HonkytonkPiano: Byte = 4
    public static let ElectricPiano1: Byte = 5
    public static let ElectricPiano2: Byte = 6
    public static let Harpsichord: Byte = 7
    public static let Clavi: Byte = 8
    public static let Celesta: Byte = 9
    public static let Glockenspiel: Byte = 10
    public static let MusicBox: Byte = 11
    public static let Vibraphone: Byte = 12
    public static let Marimba: Byte = 13
    public static let Xylophone: Byte = 14
    public static let TubularBells: Byte = 15
    public static let Dulcimer: Byte = 16
    public static let DrawbarOrgan: Byte = 17
    public static let PercussiveOrgan: Byte = 18
    public static let RockOrgan: Byte = 19
    public static let ChurchOrgan: Byte = 20
    public static let ReedOrgan: Byte = 21
    public static let Accordion: Byte = 22
    public static let Harmonica: Byte = 23
    public static let TangoAccordion: Byte = 24
    public static let AcousticGuitarnylon: Byte = 25
    public static let AcousticGuitarsteel: Byte = 26
    public static let ElectricGuitarjazz: Byte = 27
    public static let ElectricGuitarclean: Byte = 28
    public static let ElectricGuitarmuted: Byte = 29
    public static let OverdrivenGuitar: Byte = 30
    public static let DistortionGuitar: Byte = 31
    public static let Guitarharmonics: Byte = 32
    public static let AcousticBass: Byte = 33
    public static let ElectricBassfinger: Byte = 34
    public static let ElectricBasspick: Byte = 35
    public static let FretlessBass: Byte = 36
    public static let SlapBass1: Byte = 37
    public static let SlapBass2: Byte = 38
    public static let SynthBass1: Byte = 39
    public static let SynthBass2: Byte = 40
    public static let Violin: Byte = 41
    public static let Viola: Byte = 42
    public static let Cello: Byte = 43
    public static let Contrabass: Byte = 44
    public static let TremoloStrings: Byte = 45
    public static let PizzicatoStrings: Byte = 46
    public static let OrchestralHarp: Byte = 47
    public static let Timpani: Byte = 48
    public static let StringEnsemble1: Byte = 49
    public static let StringEnsemble2: Byte = 50
    public static let SynthStrings1: Byte = 51
    public static let SynthStrings2: Byte = 52
    public static let ChoirAahs: Byte = 53
    public static let VoiceOohs: Byte = 54
    public static let SynthVoice: Byte = 55
    public static let OrchestraHit: Byte = 56
    public static let Trumpet: Byte = 57
    public static let Trombone: Byte = 58
    public static let Tuba: Byte = 59
    public static let MutedTrumpet: Byte = 60
    public static let FrenchHorn: Byte = 61
    public static let BrassSection: Byte = 62
    public static let SynthBrass1: Byte = 63
    public static let SynthBrass2: Byte = 64
    public static let SopranoSax: Byte = 65
    public static let AltoSax: Byte = 66
    public static let TenorSax: Byte = 67
    public static let BaritoneSax: Byte = 68
    public static let Oboe: Byte = 69
    public static let EnglishHorn: Byte = 70
    public static let Bassoon: Byte = 71
    public static let Clarinet: Byte = 72
    public static let Piccolo: Byte = 73
    public static let Flute: Byte = 74
    public static let Recorder: Byte = 75
    public static let PanFlute: Byte = 76
    public static let BlownBottle: Byte = 77
    public static let Shakuhachi: Byte = 78
    public static let Whistle: Byte = 79
    public static let Ocarina: Byte = 80
    public static let Lead1square: Byte = 81
    public static let Lead2sawtooth: Byte = 82
    public static let Lead3calliope: Byte = 83
    public static let Lead4chiff: Byte = 84
    public static let Lead5charang: Byte = 85
    public static let Lead6voice: Byte = 86
    public static let Lead7fifths: Byte = 87
    public static let Lead8basslead: Byte = 88
    public static let Pad1newage: Byte = 89
    public static let Pad2warm: Byte = 90
    public static let Pad3polysynth: Byte = 91
    public static let Pad4choir: Byte = 92
    public static let Pad5bowed: Byte = 93
    public static let Pad6metallic: Byte = 94
    public static let Pad7halo: Byte = 95
    public static let Pad8sweep: Byte = 96
    public static let FX1rain: Byte = 97
    public static let FX2soundtrack: Byte = 98
    public static let FX3crystal: Byte = 99
    public static let FX4atmosphere: Byte = 100
    public static let FX5brightness: Byte = 101
    public static let FX6goblins: Byte = 102
    public static let FX7echoes: Byte = 103
    public static let FX8scifi: Byte = 104
    public static let Sitar: Byte = 105
    public static let Banjo: Byte = 106
    public static let Shamisen: Byte = 107
    public static let Koto: Byte = 108
    public static let Kalimba: Byte = 109
    public static let Bagpipe: Byte = 110
    public static let Fiddle: Byte = 111
    public static let Shanai: Byte = 112
    public static let TinkleBell: Byte = 113
    public static let Agogo: Byte = 114
    public static let SteelDrums: Byte = 115
    public static let Woodblock: Byte = 116
    public static let TaikoDrum: Byte = 117
    public static let MelodicTom: Byte = 118
    public static let SynthDrum: Byte = 119
    public static let ReverseCymbal: Byte = 120
    public static let GuitarFretNoise: Byte = 121
    public static let BreathNoise: Byte = 122
    public static let Seashore: Byte = 123
    public static let BirdTweet: Byte = 124
    public static let TelephoneRing: Byte = 125
    public static let Helicopter: Byte = 126
    public static let Applause: Byte = 127
    public static let Gunshot: Byte = 128

    /// Using the table from [this link](https://www.midi.org/specifications/item/gm-level-1-sound-set)
    public static let AcousticBassDrum: Byte = 35
    public static let BassDrum1: Byte = 36
    public static let SideStick: Byte = 37
    public static let AcousticSnare: Byte = 38
    public static let HandClap: Byte = 39
    public static let ElectricSnare: Byte = 40
    public static let LowFloorTom: Byte = 41
    public static let ClosedHiHat: Byte = 42
    public static let HighFloorTom: Byte = 43
    public static let PedalHiHat: Byte = 44
    public static let LowTom: Byte = 45
    public static let OpenHiHat: Byte = 46
    public static let LowMidTom: Byte = 47
    public static let HiMidTom: Byte = 48
    public static let CrashCymbal1: Byte = 49
    public static let HighTom: Byte = 50
    public static let RideCymbal1: Byte = 51
    public static let ChineseCymbal: Byte = 52
    public static let RideBell: Byte = 53
    public static let Tambourine: Byte = 54
    public static let SplashCymbal: Byte = 55
    public static let Cowbell: Byte = 56
    public static let CrashCymbal2: Byte = 57
    public static let Vibraslap: Byte = 58
    public static let RideCymbal2: Byte = 59
    public static let HiBongo: Byte = 60
    public static let LowBongo: Byte = 61
    public static let MuteHiConga: Byte = 62
    public static let OpenHiConga: Byte = 63
    public static let LowConga: Byte = 64
    public static let HighTimbale: Byte = 65
    public static let LowTimbale: Byte = 66
    public static let HighAgogo: Byte = 67
    public static let LowAgogo: Byte = 68
    public static let Cabasa: Byte = 69
    public static let Maracas: Byte = 70
    public static let ShortWhistle: Byte = 71
    public static let LongWhistle: Byte = 72
    public static let ShortGuiro: Byte = 73
    public static let LongGuiro: Byte = 74
    public static let Claves: Byte = 75
    public static let HiWoodBlock: Byte = 76
    public static let LowWoodBlock: Byte = 77
    public static let MuteCuica: Byte = 78
    public static let OpenCuica: Byte = 79
    public static let MuteTriangle: Byte = 80
    public static let OpenTriangle: Byte = 81

    /// Use only at start of running status. Change channel from 0 via bitwise AND with a channel.
    /// Use noteOn (or running status) with zero velocity for noteOff
    public static let noteOn: Byte = 0x90
    public static let programChange: Byte = 0xC0
    public static let drumChannel: Byte = 9

    /// Based on MIDI table from [this link](https://usermanuals.finalemusic.com/Finale2012Mac/Content/Finale/MIDI_Note_to_Pitch_Table.htm).
    /// a[0] = a0, a[3] = a3 etc.
    /// Goes up to [8] only because a[9] and some others are out of range (pitch maximum is 127).
    /// To access negative pitches, subtract a P8. c[-1] is the lowest possible pitch.
    public static let c: [Byte] = (0...8).map {12*(Byte($0)+1)}
    public static let csharp: [Byte] = c.map {$0+m2}
    public static let dflat = csharp
    public static let d: [Byte] = csharp.map {$0+m2}
    public static let dsharp: [Byte] = d.map {$0+m2}
    public static let eflat: [Byte] = dsharp
    public static let e: [Byte] = dsharp.map {$0+m2}
    public static let f: [Byte] = e.map {$0+m2}
    public static let fsharp: [Byte] = f.map {$0+m2}
    public static let gflat: [Byte] = fsharp
    public static let g: [Byte] = fsharp.map {$0+m2}
    public static let gsharp: [Byte] = g.map {$0+m2}
    public static let aflat: [Byte] = gsharp
    public static let a: [Byte] = gsharp.map {$0+m2}
    public static let asharp: [Byte] = a.map {$0+m2}
    public static let bflat: [Byte] = asharp
    public static let b: [Byte] = asharp.map{$0+m2}

    /// Offsets from the root
    public static let P1: Byte = 0
    public static let m2: Byte = 1
    public static let M2: Byte = 2
    public static let m3: Byte = 3
    public static let M3: Byte = 4
    public static let P4: Byte = 5
    public static let TT: Byte = 6
    public static let P5: Byte = 7
    public static let m6: Byte = 8
    public static let M6: Byte = 9
    public static let m7: Byte = 10
    public static let M7: Byte = 11
    public static let P8: Byte = 12

    public static let headerType: [Byte] = [0x4D, 0x54, 0x68, 0x64]
    public static let chunkType: [Byte] = [0x4D, 0x54, 0x72, 0x6B]
    public static let headerLength: [Byte] = [0x00, 0x00, 0x00, 0x06]
    public static let endOfTrack: [Byte] = [0x00, 0xFF, 0x2F, 0x00]

    /// The default value of a quarter note
    public static let defaultDivision: UInt16 = 0x60

    public enum HeaderChunkMode {
        case SingleTrack
        case SimultaneousTracks(num: UInt16)
        case IndependentTracks(num: UInt16)
        public var bytes: [Byte] {
            switch self {
            case .SingleTrack: return [0x00, 0x00]
            case .SimultaneousTracks(_): return [0x00, 0x01]
            case .IndependentTracks(_): return [0x00, 0x02]
            }
        }
    }

    /// - parameter division: defaults to 0x18 because that can get triplets evenly.
    public static func headerChunk(mode: HeaderChunkMode, division: UInt16 = defaultDivision) -> [Byte] {
        let numTracks: UInt16
        switch mode {
        case .SingleTrack: numTracks = 1
        case .SimultaneousTracks(let num), .IndependentTracks(let num): numTracks = num
        }
        return headerType + headerLength + mode.bytes + toBytes(numTracks) + toBytes(division)
    }

    /// Adds track header and end of track around contents.
    public static func track(contents: [Byte]) -> [Byte] {
        return chunkType + toBytes(UInt32(contents.count)) + contents + endOfTrack
    }

    /// Return a complete, usable MIDI file from the specified contents
    public static func file(mode: HeaderChunkMode, contents: [Byte], division: UInt16 = defaultDivision) -> [Byte] {
        return headerChunk(mode: mode, division: division) + track(contents: contents)
    }

    /// Construct a MIDI note with the specified characteristics. Does not optimize with running status, but is guaranteed to return a valid note. To stack multiple notes, use the chord function because concatenated notes from this function will play in sequence, not simultaneously.
    /// - parameter
    /// - parameter offset: from 0x00, which would play the note immediately after the previous event
    /// - parameter velocity: from 0 to 127
    /// - parameter channel: defaults to 0. Note that I use zero instead of one indexing for channels.
    public static func note(pitch: Byte, velocity: Byte, duration: UInt32, offset: UInt32 = 0, channel: Byte = 0) -> [Byte] {
        let noteOnMessage = noteOn | channel
        return toVariableLength(offset) + [noteOnMessage, pitch, velocity] + toVariableLength(duration) + [noteOnMessage, pitch, 0]
    }

    public static func note(aNote: Note) -> [Byte] {
        return note(pitch: aNote.pitch, velocity: aNote.velocity, duration: aNote.duration, offset: aNote.offset, channel: aNote.channel)
    }

    /// A note, or the root of a chord
    /// To create a drum note, use channel: MIDI.drumChannel and then pitch: MIDI.Drum.<thing>.rawValue
    public struct Note {
        public var pitch: Byte
        public var velocity: Byte
        public var duration: UInt32
        public var offset: UInt32
        public var channel: Byte
        init(pitch: Byte, velocity: Byte, duration: UInt32, offset: UInt32 = 0, channel: Byte = 0) {
            self.pitch = pitch
            self.velocity = velocity
            self.duration = duration
            self.offset = offset
            self.channel = channel
        }
    }

    /// A note in a chord whose properties are derived from the root Note
    public struct ChordMember {
        public enum Pitch {case Absolute(Byte), Interval(Byte)}
        /// from the root
        public var pitch: Pitch
        /// if nil, follow root
        public var velocity: Byte?
        /// if nil, follow root
        public var duration: UInt32?
        /// from the root
        public var offset: UInt32
        /// maximum of 0x0F; if nil, follow root
        public var channel: Byte?
        public init(pitch: Pitch, velocity: Byte? = nil, duration: UInt32? = nil, offset: UInt32 = 0, channel: Byte? = nil) {
            self.pitch = pitch
            self.velocity = velocity
            self.duration = duration
            self.offset = offset
            self.channel = channel
        }
    }

    /// Construct a MIDI chord with the specified members, whose properties derive from the root note.
    /// - parameter root: *NOT* included in the chord by default. It must be specifically added using the interval of P1.
    /// - parameter intervals: All from the root.
    /// - parameter channels: Zero indexed.
    public static func chord(root: Note, members: [ChordMember]) -> [Byte] {
        // The basic idea behind this algorithm is that we figure out when each noteOn and noteOff event occurs and place them in order from earliest to latest, computing delta times between them.
        var bytes = [Byte]()
        struct ChordEvent {
            var pitch: Byte
            var velocity: Byte
            var time: UInt32
            var channel: Byte
        }
        var events = [ChordEvent]()
        for member in members {
            let pitch: Byte; switch member.pitch {
            case .Absolute(let absolute): pitch = absolute
            case .Interval(let interval): pitch = root.pitch + interval
            }
            let velocity = member.velocity ?? root.velocity
            let channel = member.channel ?? root.channel
            let startTime = member.offset
            let endTime = startTime + (member.duration ?? root.duration)
            let noteOnEvent = ChordEvent(pitch: pitch, velocity: velocity, time: startTime, channel: channel)
            let noteOffEvent = ChordEvent(pitch: pitch, velocity: 0, time: endTime, channel: channel)
            events += [noteOnEvent, noteOffEvent]
        }
        events.sort{$0.time<$1.time}
        var lastEventTime: UInt32 = 0
        for i in 0..<events.count {
            bytes += toVariableLength(events[i].time - lastEventTime) + [noteOn | events[i].channel, events[i].pitch, events[i].velocity]
            lastEventTime = events[i].time
        }
        return bytes
    }

    /// A program change event changes the instrument used by the current track.
    public static func programChange(to: Byte, offset: UInt32 = 0, channel: Byte = 0) -> [Byte] {
        return toVariableLength(offset) + [programChange | channel, to]
    }

    /// Get delta time bytes for a given note duration. It's not in variable-length, but most functions will automatically convert it, and the toVariableLength function can also do this.
    /// - parameter number: 1 = whole note, 4 = quarter, 8 = eighth etc. **0 returns 0x00 i.e. no delay** If you need a value greater than a whole note, use multiplication on the return value of this function.
    /// - parameter dotted: defaults to false
    /// - parameter quarterNote: i.e. "division" from header chunk
    public static func duration(_ number: Int, dotted: Bool = false, quarterNote: UInt16 = defaultDivision) -> UInt32 {
        return number == 0 ? 0 : UInt32(quarterNote) * 4 * (dotted ? 3 : 2) / 2 / UInt32(number)
    }

    /// Convert from UInt32 to variable length bytes used as delta times by MIDI.
    /// Props to [Wikipedia](https://en.wikipedia.org/wiki/Variable-length_quantity) for the basic algorithm
    public static func toVariableLength(_ value: UInt32) -> [Byte] {
        var bytes = [Byte]()
        bytes.append(Byte(value & 0x7F))
        for i: UInt32 in 1...4 {
            bytes.append(Byte(((value >> (7*i)) & 0x7F) | 0x80))
        }
        bytes.reverse()
        var numberToRemove = 0
        for i in 0..<bytes.count {
            if bytes[i] == 0x80 {numberToRemove += 1}
            else {break}
        }
        bytes.removeFirst(numberToRemove)
        return bytes
    }

    /// Convert from variable length bytes (i.e. delta times) back to UInt32, on which you can do arithmetic operations.
    public static func fromVariableLength(_ deltaTime: [Byte]) -> UInt32 {
        var value: UInt32 = 0
        let numValues = deltaTime.count
        for i in 0..<numValues {
            var bits = UInt32(deltaTime[i] & 0b0111_1111) // throw away the 7th bit
            bits = bits << UInt32(7 * (numValues - i - 1)) // move it into the proper place; most significant bits are first in the array and get shifted over the most. Note that for the last one, i = numValues - 1, we want to shift by 0 because it is least significant.
            value += bits
        }
        return value
    }

    /// Helper function that can represent an 32 bit integer as a 4 byte array
    public static func toBytes(_ int: UInt32) -> [Byte] {
        var bytes: [Byte] = []
        for i in 0..<4 {
            let byte = Byte(truncatingBitPattern: int >> UInt32(8*i))
            bytes.append(byte)
        }
        return bytes.reversed()
    }

    /// Helper function that calls toBytes for a 32 bit integer and throws away the 2 zero bytes to get a 2 byte array
    public static func toBytes(_ int: UInt16) -> [Byte] {
        return Array(toBytes(UInt32(int))[2...3]) // throw away the two high order bytes (zeroes)
    }
    
    public static func tempo(bpm: Int) -> [Byte] {
        return [0x00, 0xFF, 0x51, 0x03] + toBytes(60_000_000 / UInt32(bpm))[1...3]
    }
}

import PlaygroundSupport
PlaygroundSupport.PlaygroundPage.current.needsIndefiniteExecution = true

//: This sound bank is from [Apple's sample code "AVAEMixerSample"](https://developer.apple.com/library/content/samplecode/AVAEMixerSample/Introduction/Intro.html#//apple_ref/doc/uid/TP40015134-Intro-DontLinkElementID_2)
let soundBank = Bundle.main.url(forResource: "gs_instruments", withExtension: "dls")!
var contents: [Byte] = []

// Modify contents here. I have provided a sample.
contents += MIDI.programChange(to: MIDI.BrightAcousticPiano)
contents += MIDI.note(pitch: MIDI.c[3], velocity: 60, duration: MIDI.duration(4))
contents += MIDI.note(pitch: MIDI.d[3], velocity: 80, duration: MIDI.duration(4))
contents += MIDI.note(pitch: MIDI.e[3], velocity: 100, duration: MIDI.duration(8))
contents += MIDI.note(pitch: MIDI.d[3], velocity: 80, duration: MIDI.duration(4, dotted: true))
contents += MIDI.note(pitch: MIDI.c[3], velocity: 60, duration: MIDI.duration(1))
contents += MIDI.note(pitch: MIDI.BassDrum1, velocity: 80, duration: MIDI.duration(4), channel: MIDI.drumChannel)
contents += MIDI.note(pitch: MIDI.AcousticSnare, velocity: 80, duration: MIDI.duration(4), channel: MIDI.drumChannel)
contents += MIDI.note(pitch: MIDI.BassDrum1, velocity: 80, duration: MIDI.duration(4), channel: MIDI.drumChannel)
contents += MIDI.note(pitch: MIDI.AcousticSnare, velocity: 80, duration: MIDI.duration(4), channel: MIDI.drumChannel)
contents += MIDI.programChange(to: MIDI.ElectricPiano1)
contents += MIDI.chord(
    root: MIDI.Note(pitch: MIDI.c[3], velocity: 60, duration: MIDI.duration(4)),
    members: [
        MIDI.ChordMember(pitch: .Interval(MIDI.P1)),
        MIDI.ChordMember(pitch: .Interval(MIDI.P5)),
        MIDI.ChordMember(pitch: .Interval(MIDI.M2), offset: MIDI.duration(4)),
        MIDI.ChordMember(pitch: .Interval(MIDI.M6), offset: MIDI.duration(4)),
        MIDI.ChordMember(pitch: .Interval(MIDI.M3), duration: MIDI.duration(8), offset: MIDI.duration(4)*2),
        MIDI.ChordMember(pitch: .Interval(MIDI.M7), duration: MIDI.duration(8), offset: MIDI.duration(4)*2),
        MIDI.ChordMember(pitch: .Interval(MIDI.P5), duration: MIDI.duration(4, dotted: true), offset: MIDI.duration(4)*5/2),
        MIDI.ChordMember(pitch: .Interval(MIDI.P1), duration: MIDI.duration(1), offset: MIDI.duration(4)*4),
        MIDI.ChordMember(pitch: .Interval(MIDI.P8), duration: MIDI.duration(1), offset: MIDI.duration(4)*4),
        //Because of offset specification, chord members can be provided in arbitrary order.
        //The chord feature can be used to generate arbitrary polyphonic sequences with overlapping notes,
        //as well as simple block or arpeggiated chords
        MIDI.ChordMember(pitch: .Absolute(MIDI.BassDrum1), channel: MIDI.drumChannel),
        MIDI.ChordMember(pitch: .Absolute(MIDI.AcousticSnare), offset: MIDI.duration(4), channel: MIDI.drumChannel),
        MIDI.ChordMember(pitch: .Absolute(MIDI.BassDrum1), offset: MIDI.duration(4)*2, channel: MIDI.drumChannel),
        MIDI.ChordMember(pitch: .Absolute(MIDI.AcousticSnare), offset: MIDI.duration(4)*3, channel: MIDI.drumChannel),
        MIDI.ChordMember(pitch: .Absolute(MIDI.CrashCymbal1), offset: MIDI.duration(4)*4, channel: MIDI.drumChannel)
    ])
contents += MIDI.programChange(to: MIDI.Lead1square)
let intervals = [MIDI.P1, MIDI.M3, MIDI.P5, MIDI.P8]
for _ in 0..<16 {
    contents += MIDI.note(pitch: intervals[Int(arc4random_uniform(UInt32(intervals.count)))] + MIDI.c[3], velocity: 60, duration: MIDI.duration(16))
}

// This will play the contents.
let data = Data(bytes:MIDI.file(mode: .SingleTrack, contents: contents))
let player = try! AVMIDIPlayer(data: data, soundBankURL: soundBank)
player.play()
