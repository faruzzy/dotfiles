{
    "env": {
        "browser": true,
		"node": true,
        "es6": true
    },

	"extends": [
		"eslint:recommended",
		"plugin:import/errors",
		"plugin:import/warnings",
		"kentcdodds/possible-errors",
		"kentcdodds/best-practices",
		"kentcdodds/es6/possible-errors",
		"kentcdodds/import",
		"plugin:promise/recommended",
		"xo/esnext",
		"plugin:unicorn/recommended",
		"google"
	],

    "parserOptions": {
		"ecmaVersion": 6,
        "sourceType": "module"
    },

    "rules": {
        "indent": [
            "error",
			4,
            "tab"
        ],

		"max-len": ["error", 120, {
			"ignoreComments": true,
			"ignoreUrls": true,
			"tabWidth": 2
		}],

		"no-unused-vars": ["error", {
			"vars": "all",
			"args": "after-used",
			"argsIgnorePattern": "(^reject$|^_$)",
			"varsIgnorePattern": "(^_$)"
		}],

        "linebreak-style": [
            "error",
            "unix"
        ],

        "quotes": [
            "error",
            "single"
        ],

        "semi": [
            "error",
            "always"
        ],


		"eslint-comments/disable-enable-pair": "error",
		"eslint-comments/no-duplicate-disable": "error",
		"eslint-comments/no-unlimited-disable": "error",
		"eslint-comments/no-unused-disable": "error",
		"eslint-comments/no-unused-enable": "error",

		"optimize-regex/optimize-regex": "warn"

    }
}