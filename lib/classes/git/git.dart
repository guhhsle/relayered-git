import 'dart:convert';
import 'dart:io';
import 'package:dart_git/dart_git.dart';
import 'package:flutter/material.dart';
import 'package:go_git_dart/go_git_dart_async.dart';
import 'package:relayered/classes/git/git_desktop.dart';
import '../../data.dart';

const repoPath = '';
const sshPrivateKey = '';
const sshPassword = '';
const gitAuthorEmail = 'guhhsle@proton.me';
const gitAuthorName = 'guhhsle';

class Git {
  String get path => Pref.path.value;

  Future<void> init() async {}

  Future<void> sync({bool doNotThrow = false}) async {}

  Future<void> push() async {
    final repo = await GitAsyncRepository.load(path);
    final canPush = await repo.canPush();
    debugPrint('Can push : $canPush');

    var remoteName = 'origin';
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        var bindings = GitBindingsAsync();
        await bindings.push(
          remoteName,
          path,
          utf8.encode(sshPrivateKey),
          sshPassword,
        );
      } catch (e) {
        rethrow;
      }
    } else if (Platform.isMacOS || Platform.isLinux) {
      return await gitPushViaExecutable(
        privateKey: sshPrivateKey,
        privateKeyPassword: sshPassword,
        remoteName: remoteName,
        repoPath: path,
      );
    }
  }

  Future<void> merge() async {
    var repo = await GitAsyncRepository.load(path);
    var branch = await repo.currentBranch();

    var branchConfig = repo.config.branch(branch);
    if (branchConfig == null) {
      var ex = Exception("Branch '$branch' not in config");
      throw ex;
    }

    try {
      // try to get the remoteBranch
      await repo.remoteBranch(
        branchConfig.remote!,
        branchConfig.trackingBranch()!,
      );
    } catch (e) {
      debugPrint('Error merging: $e');
      rethrow;
    }

    var author = GitAuthor(
      email: gitAuthorEmail,
      name: gitAuthorName,
    );
    return repo.mergeCurrentTrackingBranch(author: author);
  }

  Future<void> _commit({
    required String message,
    required String authorEmail,
    required String authorName,
  }) async {
    var repo = await GitAsyncRepository.load(path);
    var author = GitAuthor(name: authorName, email: authorEmail);
    await repo.commit(message: message, author: author);
  }

  Future<void> addAllAndCommit(String commitMessage) async {
    await _add(".");
    await _commit(
      message: commitMessage,
      authorEmail: gitAuthorEmail,
      authorName: gitAuthorName,
    );
  }

  Future<void> _add(String pathSpec) async {
    var repo = await GitAsyncRepository.load(path);
    await repo.add(pathSpec);
  }
}
