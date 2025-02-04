import 'package:build/build.dart' show BuildStep, log;
import 'package:http_methods/http_methods.dart' show isHttpMethod;
import 'package:source_gen/source_gen.dart' as g;
import 'package:analyzer/dart/element/element.dart'
    show ClassElement, ExecutableElement;
import 'package:analyzer/dart/element/type.dart' show DartType;

import '../api_builder.dart' show EndPoint;

// Type checkers that we need later
final _endPointType = g.TypeChecker.fromRuntime(EndPoint);

/// A representation of a handler that was annotated with [EndPoint].
class Handler {
  final String verb, route;
  final ExecutableElement element;

  Handler(this.verb, this.route, this.element);

  /// If this handler has a payload
  bool get hasPayload =>
      element.parameters.length > 1 &&
      !element.parameters.last.type.isDartCoreString;

  DartType get payloadType => element.parameters.last.type;
}

/// Find members of a class annotated with [EndPoint].
List<ExecutableElement> _getAnnotatedElementsOrderBySourceOffset(
    ClassElement cls) {
  return <ExecutableElement>[]
    ..addAll(cls.methods.where(_endPointType.hasAnnotationOfExact))
    ..addAll(cls.accessors.where(_endPointType.hasAnnotationOfExact))
    ..sort((a, b) => (a.nameOffset ?? -1).compareTo(b.nameOffset ?? -1));
}

abstract class EndPointGenerator extends g.Generator {
  Future<String> generateForClasses(Map<ClassElement, List<Handler>> classes);

  @override
  Future<String> generate(g.LibraryReader library, BuildStep step) async {
    // Create a map from ClassElement to list of annotated elements sorted by
    // offset in source code, this is not type checked yet.
    final classes = <ClassElement, List<Handler>>{};
    for (final cls in library.classes) {
      final elements = _getAnnotatedElementsOrderBySourceOffset(cls);
      if (elements.isEmpty) {
        continue;
      }
      log.info('found EndPoint annotations in ${cls.name}');

      classes[cls] = elements
          .map((e) => _endPointType.annotationsOfExact(e).map((a) => Handler(
                a.getField('verb').toStringValue(),
                a.getField('route').toStringValue(),
                e,
              )))
          .expand((i) => i)
          .toList();
    }
    if (classes.isEmpty) {
      return null; // nothing to do if nothing was annotated
    }

    // TODO: Type checking at code-gen time would be nice to have.
    for (final handlers in classes.values) {
      for (final h in handlers) {
        if (!isHttpMethod(h.verb)) {
          throw g.InvalidGenerationSourceError(
            '"${h.verb}" is not a valid HTTP verb.',
            element: h.element,
          );
        }
      }
    }

    // Build library and emit code with all generate methods.
    return generateForClasses(classes);
  }
}
