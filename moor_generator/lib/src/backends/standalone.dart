import 'dart:io';

import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:cli_util/cli_util.dart';
import 'package:moor_generator/src/backends/common/driver.dart';
import 'package:path/path.dart' as p;

import 'package:moor_generator/src/backends/plugin/plugin.dart';

class StandaloneMoorAnalyzer {
  // the analyzer plugin package is wrapping a lot of unstable analyzer apis
  // for us. It's also managed by the Dart team, so creating a fake plugin to
  // create Dart analysis drivers seems like the most stable approach.
  final MoorPlugin _fakePlugin;

  ResourceProvider get resources => _fakePlugin.resourceProvider;

  StandaloneMoorAnalyzer(ResourceProvider provider)
      : _fakePlugin = MoorPlugin(provider);

  factory StandaloneMoorAnalyzer.inMemory() {
    return StandaloneMoorAnalyzer(MemoryResourceProvider());
  }

  Future<void> init({String sdkPath}) async {
    final tempDir = p.join(Directory.systemTemp.path, 'moor_generator');
    sdkPath ??= getSdkPath();

    final result = await _fakePlugin.handlePluginVersionCheck(
      PluginVersionCheckParams(
        tempDir,
        sdkPath,
        _fakePlugin.version,
      ),
    );

    if (!result.isCompatible) {
      throw StateError('Fake plugin is incompatible with itself?');
    }
  }

  MoorDriver createAnalysisDriver(String path) {
    return _fakePlugin.createAnalysisDriver(ContextRoot(path, []));
  }
}
