#include <Napi.h>

napi_value _init(napi_env, napi_value);

NAPI_MODULE(demo, _init)
