import test from 'ava';
import { createRequire } from 'module';

const addon = createRequire(import.meta.url)('../libdemo.node');

test("Demo", t => {
  t.is(addon.name, "swift-napi");
  t.is(addon.hello(), "Hello, Node-API ~");
  t.is(addon.add(111, 22), 133);

  let cb;
  addon.callback(content => cb = content);
  t.is(cb, "Hello, callback");
});
