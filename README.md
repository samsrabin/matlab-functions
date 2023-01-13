Add the following to your `startup.m`:

```matlab
addpath(genpath('/path/to/your/clone/of/this/repo'))
```



If you don't know where your `startup.m` is and you're in the MATLAB GUI, you can do

```matlab
edit(fullfile(userpath,'startup.m'))
```

and it will open for you (creating the file if it doesn't already exist).



If you're not in the MATLAB GUI, do

```matlab
fullfile(userpath, 'startup.m')
```

to get the path of the file you should create.