# Configure Zwave2mqtt

### Generate Zwave master key
```
> openssl rand -hex 16 | sed -e ‘s/([0-9][0-9])/0x\1,/g’ -e ‘s/,$//’
```