import 'package:flutter/material.dart';
import 'folder_list_page.dart'; // Import the FolderListPage
import 'package:flutter_logs/flutter_logs.dart'; // Import flutter_logs

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLogs.initLogs(
    logLevelsEnabled: [LogLevel.INFO], // Enable all log levels
    timeStampFormat: TimeStampFormat.DATE_FORMAT_1, // Use the enum value directly
    directoryStructure: DirectoryStructure.FOR_DATE, // Specify directory structure
    logFileExtension: LogFileExtension.TXT, // Correct enum usage
    logsWriteDirectoryName: 'logs', // Optional: Specify the directory name for logs
    logsExportDirectoryName: 'exported_logs', // Optional: Specify the directory name for exported logs
    logsExportZipFileName: 'logs_export', // Optional: Specify the zip file name for exported logs
    logsRetentionPeriodInDays: 14, // Optional: Set logs retention period
    zipsRetentionPeriodInDays: 3, // Optional: Set zips retention period
    autoDeleteZipOnExport: false, // Optional: Auto-delete zips on export
    autoClearLogs: true, // Optional: Auto-clear logs
    autoExportErrors: true, // Optional: Auto-export errors
    encryptionEnabled: false, // Optional: Enable encryption
    encryptionKey: "", // Optional: Encryption key
    logSystemCrashes: true, // Optional: Log system crashes
    isDebuggable: true, // Optional: Enable debugging
    debugFileOperations: true, // Optional: Debug file operations
    attachTimeStamp: true, // Optional: Attach timestamp to logs
    attachNoOfFiles: true, // Optional: Attach number of files to logs
    zipFilesOnly: false, // Optional: Zip files only
    singleLogFileSize: 2, // Optional: Set single log file size in MB
    enabled: true, // Optional: Enable logging
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FolderListPage(), // Set FolderListPage as the home page
    );
  }
}
