import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadCard extends StatelessWidget {
  final bool isUploading;
  final VoidCallback onUpload;
  final PlatformFile? pickedFile;
  final VoidCallback onRemoveFile;

  const UploadCard({
    super.key,
    required this.isUploading,
    required this.onUpload,
    this.pickedFile,
    required this.onRemoveFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Have a Prescription?",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Upload it and we'll add the tests for you.",
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isUploading ? null : onUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1f7cff),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Upload Now",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          if (pickedFile != null) ...[
            const SizedBox(height: 16),
            FilePreview(
              file: pickedFile!,
              onRemove: onRemoveFile,
            ),
          ],
        ],
      ),
    );
  }
}

class FilePreview extends StatelessWidget {
  final PlatformFile file;
  final VoidCallback onRemove;

  const FilePreview({
    super.key,
    required this.file,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  "${(file.size / 1024).toStringAsFixed(2)} KB",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, color: Colors.white70),
          )
        ],
      ),
    );
  }
}
