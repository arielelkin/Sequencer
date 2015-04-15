# Sequencer
Example use of the sequencer plugin for [The Amazing Audio Engine](https://github.com/TheAmazingAudioEngine/TheAmazingAudioEngine).

##Use
Clone this repository, add `pod 'TheAmazingAudioEngine'` to your pod file or [manually add The Amazing Audio Engine](http://theamazingaudioengine.com/doc/_getting-_started.html).

In this example we will play a sound every [quarter note](http://en.wikipedia.org/wiki/Quarter_note):

    //Add an audio file to your Xcode project and get its `NSURL` :
    NSURL *woodblockSoundURL = [[NSBundle mainBundle] URLForResource:@"woodblock" withExtension:@"caf"];

    //Next, specify when the sound should play in relation to the whole sequence, 
    //by adding instances of AESequencerBeat to your AESequencerChannelSequence. 
    //The onset property of an AESequencerBeat should be between 0  and 1. 
    AESequencerChannelSequence *woodblockSoundSequence = [AESequencerChannelSequence new];
    [woodblockSoundSequence addBeat:[AESequencerBeat beatWithOnset:0]];
    [woodblockSoundSequence addBeat:[AESequencerBeat beatWithOnset:0.25]];
    [woodblockSoundSequence addBeat:[AESequencerBeat beatWithOnset:0.50]];
    [woodblockSoundSequence addBeat:[AESequencerBeat beatWithOnset:0.75]];

    //Then, create a AESequencerChannel that will play the sequence:
    woodBlockSoundChannel = [AESequencerChannel sequencerChannelWithAudioFileAt:woodblockSoundURL
                                                                audioController:audioController
                                                                   withSequence:woodblockSoundSequence
                                                    numberOfFullBeatsPerMeasure:4
                                                                          atBPM:120];

    //Add the channel to the `AEAudioController`:
    [audioController addChannels:@[woodBlockSoundChannel]];

    //Tell it to start playing:
    woodBlockSoundChannel.sequenceIsPlaying = true;

Happy sequencing!
