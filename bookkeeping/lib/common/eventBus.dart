/*
事件总线
在APP中，我们经常会需要一个广播机制，用以跨页面事件通知，
比如一个需要登录的APP中，页面会关注用户登录或注销事件，来进行一些状态更新。
这时候，一个事件总线便会非常有用，事件总线通常实现了订阅者模式，
订阅者模式包含发布者和订阅者两种角色，可以通过事件总线来触发事件和监听事件，
本节我们实现一个简单的全局事件总线，我们使用单例模式，代码如下：
*/

/// 订阅者回调签名
typedef void EventCallback(arg);

/// 单例
var bus = new EventBus();

class EventBus {
  /// 记账页面事件
  String bookkeepingEventName = 'bookkeeping';

  EventBus._internal();

  static EventBus _singleton = new EventBus._internal();

  factory EventBus() => _singleton;

  // 保存事件订阅者队列，key:事件名(id)，value:对应事件的订阅者队列
  var _emap = new Map<Object, List<EventCallback>>();

  /// 添加订阅者
  void add(eventName, EventCallback f) {
    if (eventName == null || f == null) return;
    _emap[eventName] ??= new List<EventCallback>();
    _emap[eventName].add(f);
  }

  /// 移出订阅者 f可选参数
  void remove(eventName, [EventCallback f]) {
    var list = _emap[eventName];
    if (list == null || eventName == null) return;
    if (f == null) {
      _emap[eventName] = null;
    } else {
      _emap.remove(f);
    }
  }

  /// 触发事件，事件触发后该事件所有订阅者会被调用
  void trigger(eventName, [arg]) {
    var list = _emap[eventName];
    if (list == null) return;
    int len = list.length - 1;
    // 反向遍历，防止在订阅者在回调中移除自身带来的下表错位
    for (var i = len; i >= 0; i--) {
      list[i](arg);
    }
  }
}
