import文件夹的作用是什么？
-------------------------------------------------------------------------------

这个文件夹提供了一种管理配置文件新方式，让您可以省去每次更新或升级服务端后，
都必须重新配置服务端conf文件的麻烦。

How does this work?
-------------------------------------------------------------------------------

Place only the settings you have changed in the import files.
For example, if you want to change a value in /battle/exp.conf:

	// Rate at which exp. is given. (Note 2)
	base_exp_rate: 700

You could instead copy the setting into /import/battle_conf.txt,
and you'll eliminate any problems updating in the future.

Neat, isn't it?

- Semi-guide by Ajarn / Euphy