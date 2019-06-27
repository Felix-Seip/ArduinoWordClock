import 'package:http/http.dart' as http;

import '../clock_rest_commands.dart';

class WordClockRestCommands extends ClockRestCommands {
  WordClockRestCommands(String _ip) {
    super.ip = _ip;
    super.client = http.Client();
  }

  void showFreya() {
    sendClockCommand("wordclockfreya", "");
  }
}
