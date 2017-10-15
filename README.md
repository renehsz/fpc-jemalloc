# fpc-jemalloc
A fast freepascal memory manager using [jemalloc](https://github.com/jemalloc/jemalloc).

To build, first run ``build-jemalloc.sh``.
Then, in every project where you want to use jemalloc as the allocator, make sure the unit ``fpc_jemalloc`` is the first unit included in your program. That way, no other units can allocate memory before this unit initializes.

## LICENSE
The freepascal bindings are released under the MIT license (see [LICENSE](LICENSE) file). The jemalloc code is released under their own [license](https://github.com/jemalloc/jemalloc/blob/dev/COPYING).
