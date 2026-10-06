require("mdxsnap").setup({
	-- 画像の保存先（DefaultPastePathType = "relative" ならプロジェクトルートからの相対パス）
	DefaultPastePath = "snaps/images/posts",
	DefaultPastePathType = "relative",

	-- プロジェクトごとの上書き（上から順に評価され、最初にマッチしたものが使われる）
	ProjectOverrides = {
		{
			matchType = "projectName",
			matchValue = "portfolio",
			PastePath = "client/src/images/posts/",
			PastePathType = "relative",
			customImports = {
				{
					line = 'import { Image } from "astro:assets";',
					checkRegex = "astro:assets",
				},
				{
					line = 'import { ImportImage } from "@/lib/functions";',
					checkRegex = "@/lib/functions",
				},
			},
			customTextFormat = '<Image alt="%s" src={ImportImage("%s")} />',
		},
		{
			matchType = "projectName",
			matchValue = "zenn-articles",
			PastePath = "images",
			PastePathType = "relative",
		},
	},

	customImports = {},

	-- %s が2つなら 1つ目が alt（ファイル名）、2つ目が画像パス
	customTextFormat = "![%s](%s)",
})
