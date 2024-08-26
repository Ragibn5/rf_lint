// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:yaml/yaml.dart';

abstract class ClassNameRule extends DartLintRule {
  const ClassNameRule({required LintCode code}) : super(code: code);

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  );

  List<ClassElement> getSubclassElementList({
    required RegExp regExp,
    required ClassElement element,
  }) {
    // Iterate over all classes in the same library
    final library = element.library;

    final List<ClassElement> classElements = [];
    for (var subTypeElement
        in library.topLevelElements.whereType<ClassElement>()) {
      // check if the class extends the rootElement
      final superClass = subTypeElement.supertype;
      if (superClass?.element == element) {
        final subclassName = subTypeElement.name;
        if (!regExp.hasMatch(subclassName)) {
          classElements.add(subTypeElement);
        }
      }
    }

    return classElements;
  }

  ParsedUnitResult? _findDeclarationUnit(Element element) {
    final session = element.session;
    final parsedLibResult = (element.library != null
        ? session?.getParsedLibraryByElement(element.library!)
        : null) as ParsedLibraryResult?;

    if (parsedLibResult == null) {
      return null;
    } else {
      return _getFirstMatch(element, parsedLibResult);
    }
  }

  ParsedUnitResult? _getFirstMatch(
    Element element,
    ParsedLibraryResult parsedLibResult,
  ) {
    for (final unit in parsedLibResult.units) {
      if (_containsElement(unit, element)) {
        return unit;
      }
    }
    return null;
  }

  bool _containsElement(ParsedUnitResult unit, Element element) {
    for (final declaration in unit.unit.declarations) {
      if (declaration.declaredElement == element) {
        return true;
      }
    }
    return false;
  }

  Map<String, dynamic> loadConfig() {
    printDirStructure(Directory("."));
    final rawConfigFile = File('rf_lint_config.yaml');
    final uriConfigFile = File.fromUri(rawConfigFile.uri);

    // If config file does not exist, return empty config map.
    if (!uriConfigFile.existsSync()) {
      print("Could not find the file");
      return {};
    }

    print("File exists");

    // Try read and parse as yaml config.
    // If
    final optionsString = uriConfigFile.readAsStringSync();
    Object? yaml;
    try {
      yaml = loadYaml(optionsString) as Object?;
    } catch (e, st) {
      return {};
    }

    return (yaml is Map<String, dynamic>) ? yaml : {};
  }

  void printDirStructure(Directory directory){
    var list = directory.list(followLinks: false);
    list.forEach((e) {
      print("Child of ${directory.path}: ${e.path}");
      if(e.statSync().type == FileSystemEntityType.directory){
        printDirStructure(Directory(e.path));
      }
    });
  }
}
