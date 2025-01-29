import 'package:file_picker/file_picker.dart';

class FilePickerService {
  Future<String?> pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null) {
        return result.files.single.path;
      }
      return null;
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  Future<List<String>> pickMultipleAudioFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result != null) {
        return result.paths
            .where((path) => path != null)
            .map((path) => path!)
            .toList();
      }
      return [];
    } catch (e) {
      print('Error picking files: $e');
      return [];
    }
  }
} 