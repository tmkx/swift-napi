const addon = require('./libdemo.node')

console.log(Object.getOwnPropertyDescriptors(addon))
console.log(addon.name);
console.log(addon.hello());
console.log(addon.add(333, 333));
addon.callback(console.log);
