import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

/*
StateDescriptor
Atom
Selector
StateStore
useModel
useAction
*/

typedef T GetStateValue<T>(StateDescriptor desc);
typedef T SelectorEvaluator<T>(GetStateValue get);
typedef void Action(GetStateValue get);

class StateDescriptor<T> {
  String name;
  T initialValue;

  StateDescriptor(this.name, this.initialValue);
}

class Atom<T> extends StateDescriptor<T> {
  Atom(name, initalValue) : super(name, initalValue);
}

class Selector<T> extends StateDescriptor<T> {
  SelectorEvaluator<T> eval;
  Selector(String name, this.eval) : super(name, null);
}

class _EvalResult<T> {
  T result;
  List<String> dependencies;
  _EvalResult(this.result, this.dependencies);
}

class StateStore {
  Map<String, dynamic> states = {};

  StateStore();

  factory StateStore.of(BuildContext context) {
    return Provider.of<StateStore>(context);
  }

  dynamic getModelValue(StateDescriptor desc) {
    var modelValue;
    if (states.containsKey(desc.name)) {
      modelValue = states[desc.name];
    } else {
      modelValue = desc.initialValue;
      states[desc.name] = modelValue;
    }
    return modelValue;
  }

  dynamic _eval(StateDescriptor desc, GetStateValue get) {
    if (desc is Selector) {
      return desc.eval(get);
    } else {
      return getModelValue(desc);
    }
  }

  _EvalResult eval(StateDescriptor desc) {
    var deps = <String>[];
    var get;
    get = (desc) {
      var val = _eval(desc, get);
      if (desc is Atom) {
        deps.add(desc.name);
      }
      return val;
    };
    var value = get(desc);
    return _EvalResult(value, deps);
  }
}

T useModel<T>(StateDescriptor desc) {
  var context = useContext();
  var store = StateStore.of(context);

  var enter = useState(<String>[]);
  var leave = useState(<String>[]);
  var deps = useState(<String>[]);
  var value;

  var reeval = useMemoized(() => () {
        var result = store.eval(desc);
        value.value = result.result;

        enter.value = result.dependencies
            .where((element) => !deps.value.contains(element))
            .toList();
        leave.value = deps.value
            .where((element) => !result.dependencies.contains(element))
            .toList();
        deps.value = result.dependencies;
      });

  useEffect(() {
    enter.value.map((name) => store.states[name]).forEach((element) {
      if (element is Listenable) element.addListener(reeval);
    });
    leave.value.map((name) => store.states[name]).forEach((element) {
      if (element is Listenable) element.removeListener(reeval);
    });
    return () {
      deps.value.map((name) => store.states[name]).forEach((element) {
        if (element is Listenable) element.removeListener(reeval);
      });
    };
  }, [enter, leave]);

  var result = useMemoized(() {
    var result = store.eval(desc);
    result.dependencies.map((name) => store.states[name]).forEach((element) {
      element.addListener(reeval);
    });
    deps.value = result.dependencies;
    return result;
  });
  value = useState(result.result);

  return value.value;
}

VoidCallback useAction(Action action) {
  var context = useContext();
  var store = StateStore.of(context);

  var get = (StateDescriptor desc) {
    var value = store.eval(desc).result;
    return value;
  };

  return () => action(get);
}
