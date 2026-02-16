# Minimal mmcv.Registry / build_from_cfg shim for environments without mmcv (e.g. Mac).


class Registry:
    def __init__(self, name, build_func=None):
        self._name = name
        self._module_dict = {}

    def register_module(self, name=None, force=False, module=None):
        def _register(cls):
            _name = name if name is not None else cls.__name__
            if not force and _name in self._module_dict:
                raise KeyError(f"{_name} already registered in {self._name}")
            self._module_dict[_name] = cls
            return cls

        if module is not None:
            _register(module)
            return None
        return _register

    def get(self, key):
        return self._module_dict[key]

    def build(self, cfg, default_args=None, **kwargs):
        cfg = cfg.copy() if isinstance(cfg, dict) else dict(type=cfg)
        default_args = default_args or {}
        default_args.update(kwargs)
        obj_type = cfg.pop("type")
        obj_cls = self._module_dict[obj_type]
        return obj_cls(**{**cfg, **default_args})


def build_from_cfg(cfg, registry, default_args=None, **kwargs):
    if not isinstance(cfg, dict):
        raise TypeError(f"cfg must be a dict, got {type(cfg)}")
    if "type" not in cfg and (default_args is None or "type" not in default_args):
        raise KeyError("cfg or default_args must contain 'type'")
    cfg = cfg.copy()
    default_args = default_args or {}
    default_args.update(kwargs)
    return registry.build(cfg, default_args=default_args)
