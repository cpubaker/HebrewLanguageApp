import 'learning_audio_player.dart';

typedef VerbAudioPlayer = LearningAudioPlayer;
typedef CreateVerbAudioPlayer = CreateLearningAudioPlayer;

LearningAudioPlayer createAssetVerbAudioPlayer() =>
    createAssetLearningAudioPlayer();

class AssetVerbAudioPlayer extends AssetLearningAudioPlayer {
  AssetVerbAudioPlayer({super.assetBundle, super.player});
}
