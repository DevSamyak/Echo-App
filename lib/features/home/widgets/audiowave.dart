import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Audiowave extends ConsumerStatefulWidget {
  final String path;
  const Audiowave(
    {super.key,required this.path}
  );

  @override
  ConsumerState<Audiowave> createState() => _AudiowaveState();
}

class _AudiowaveState extends ConsumerState<Audiowave> {
  late final PlayerController playerController;

  @override
  void initState() {
    
    super.initState();
    playerController = PlayerController();
    initAudioPlayer();
  }

  Future<void> playAndPause() async {
    if (playerController.playerState == PlayerState.playing) {
      await playerController.pausePlayer();
    } else {
      await playerController.startPlayer();
    }
    if (mounted) {
      setState(() {});
    }
  }

  void initAudioPlayer() async {
    await playerController.preparePlayer(
      path: widget.path,
      shouldExtractWaveform: true,
    );
    await playerController.setFinishMode(finishMode: FinishMode.stop);
    if (mounted) {
      setState(() {});
    }
  }
  @override
  void dispose() {
  
    playerController.dispose();
    super.dispose();
    
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: playAndPause, 
          icon: Icon(
            playerController.playerState.isPlaying
            ?CupertinoIcons.pause_solid
            :CupertinoIcons.play_arrow_solid
          )
        ),
        Expanded(
          child: AudioFileWaveforms(
            size:const Size(double.infinity, 100) , 
            playerController: playerController,
            playerWaveStyle:const PlayerWaveStyle(
              fixedWaveColor: Pallete.borderColor,
              liveWaveColor:Pallete.gradient2,
              spacing: 6,
              showSeekLine: false
            ),
          ),
        ),
      ],
    );
  }
}