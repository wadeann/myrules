# Rules — omp 粘性规则

> 每次请求都随 system prompt 携带，永不因长对话被遗忘。
> 只放最硬的约束，绝不啰嗦。

- 未经明确要求，不 commit / push / tag / branch。
- 不修改 build/、Strata-data/、third_party/、vendor/ 下的产物或他人数据。
- 破坏性操作（mv/rm 数据、切分支、发布）先询问。
- 不自动安装系统级依赖。
