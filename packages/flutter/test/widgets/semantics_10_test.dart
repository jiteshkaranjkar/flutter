// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'semantics_tester.dart';

void main() {
  testWidgets('can cease to be semantics boundary after markNeedsSemanticsUpdate() has already been called once', (WidgetTester tester) async {
    final SemanticsTester semantics = new SemanticsTester(tester);

    await tester.pumpWidget(
      buildTestWidgets(
        excludeSemantics: false,
        label: 'label',
        isSemanticsBoundary: true,
      ),
    );

    // The following should not trigger an assert.
    await tester.pumpWidget(
      buildTestWidgets(
        excludeSemantics: true,
        label: 'label CHANGED',
        isSemanticsBoundary: false,
      ),
    );

    semantics.dispose();
  });
}

Widget buildTestWidgets({bool excludeSemantics, String label, bool isSemanticsBoundary}) {
  return new Directionality(
    textDirection: TextDirection.ltr,
    child: new Semantics(
      label: 'container',
      container: true,
      child: new ExcludeSemantics(
        excluding: excludeSemantics,
        child: new TestWidget(
          label: label,
          isSemanticBoundary: isSemanticsBoundary,
          child: new Column(
            children: <Widget>[
              new Semantics(
                label: 'child1',
              ),
              new Semantics(
                label: 'child2',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class TestWidget extends SingleChildRenderObjectWidget {
  const TestWidget({
    Key key,
    Widget child,
    this.label,
    this.isSemanticBoundary,
  }) : super(key: key, child: child);

  final String label;
  final bool isSemanticBoundary;

  @override
  RenderTest createRenderObject(BuildContext context) {
    return new RenderTest()
      ..label = label
      ..isSemanticBoundary = isSemanticBoundary;
  }

  @override
  void updateRenderObject(BuildContext context, RenderTest renderObject) {
    renderObject
      ..label = label
      ..isSemanticBoundary = isSemanticBoundary;
  }
}

class RenderTest extends RenderProxyBox {

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);

    if (!_isSemanticBoundary)
      return;

    config
      ..isSemanticBoundary = _isSemanticBoundary
      ..label = _label
      ..textDirection = TextDirection.ltr;

  }

  String _label = '<>';
  set label(String value) {
    if (value == _label)
      return;
    _label = value;
    markNeedsSemanticsUpdate();
  }


  bool _isSemanticBoundary = false;
  set isSemanticBoundary(bool value) {
    if (_isSemanticBoundary == value)
      return;
    _isSemanticBoundary = value;
    markNeedsSemanticsUpdate();
  }
}
