##

### Configuration Management
#### Arguments
Allows to load configurations from ARGV
It requires that all the vars are named with a common prefix
It uses '__' as a delimiter to allow nested configurations
- If the arg contains an '=' sym it will take the left string as key
  and the right as the value
- If the arg does not contain an '=' it will take the next arg as value
- If the next arg to an arg is also an arg, it will parse it as a flag.
- Also if the last element of ARGV is an arg it will
  be parsed as a flag.

##### Examples
```
  --config_env_value=3 => { 'env_value' => '3' }
  --config_env_value 3 => { 'env_value' => '3' }
  --config_env_obj__value 3 => { "env_obj" => { 'value' => '3' } }
  --config_flag --config_value 3 => { 'flag' => 'true', value => '3' }
```

#### Environment vars
Allows to load configurations from ENV
It requires that all the vars are named with a common prefix
It uses '__' as a delimiter to allow nested configurations

##### Examples
```
export CONFIG_ENV_VALUE=3 => { 'env_value' => '3' }
export CONFIG_ENV_OBJ__VALUE=3 => { "env_obj" => { 'value' => '3' } }
```


#### YAML files
YAML files can be also loaded. Those are the base for building default keys.

#### Extending from other sources

#### All in Examples



### Feature Flags / Toggles
#### Feature Flag
#### A/B Testing
#### Canarying Release
#### Extending

### Autoloader
#### AWS
##### SQS
##### S3
#### Logger
#### Rest Client
#### Sequel
#### Feature flags
