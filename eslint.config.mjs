import js from '@eslint/js';
import stylistic from '@stylistic/eslint-plugin';
import globals from 'globals';
import tseslint from 'typescript-eslint';

export default tseslint.config(
	{ ignores: ['compiled/**', 'node_modules/**', '**/*.d.ts'] },
	js.configs.recommended,
	tseslint.configs.recommended,
	{
		files: ['**/*.mjs'],
		languageOptions: { globals: globals.node }
	},
	{
		files: ['**/*.{js,ts}'],
		languageOptions: {
			sourceType: 'commonjs',
			globals: { hs: 'readonly', HSRect: 'readonly', console: 'readonly', ...globals.node }
		},
		rules: {
			'@typescript-eslint/no-require-imports': 'off',
			'@typescript-eslint/no-unused-vars': ['error', { args: 'none', caughtErrors: 'none' }]
		}
	},
	{
		files: ['**/*.{js,mjs,ts}'],
		plugins: { '@stylistic': stylistic },
		rules: {
			'@stylistic/semi': ['warn', 'always'],
			'@stylistic/indent': ['warn', 'tab'],
			'@stylistic/no-multiple-empty-lines': ['warn', { max: 1 }],
			'no-var': 'warn',
			'@stylistic/quotes': ['warn', 'single']
		}
	}
);
