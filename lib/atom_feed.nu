#the input can be:
# - a datetime-string -> datetime
# - null -> null
def parse_optional_datetime [input] {
	if $input == null { null
	} else { $input | into datetime }
}

# parse a atom feed
export def parse [
	text: string  # the entire feed in a single string
] {
	let feed = (
		$text
		| from xml
		| get feed.children
	)
	def get_single_entry [dataset, name: string] {
		$dataset | get -i $name | compact | get -i 0.children.0
	}

	let articles = (
		$feed
		| get -i entry | default [] | compact
		| get children | compact
		| each {|article|
			let content_obj = ($article | get -i content | compact | get -i 0)
			{
				#raw: $article
				title: (get_single_entry $article title)
				published: (parse_optional_datetime (get_single_entry $article published))
				updated: (parse_optional_datetime (get_single_entry $article updated))
				content: ($content_obj | get -i children.0)
				content_type: ($content_obj | get -i attributes.type)
				# TODO: link.attributes.[href,title] (multiple)
				# TODO: category.attributes.term (multiple)
			}
		}
	)

	{
		title: (get_single_entry $feed title)
		updated: (parse_optional_datetime (get_single_entry $feed updated))
		id: (get_single_entry $feed id)
		icon: (get_single_entry $feed icon)
		articles: $articles
	}
}

# open & render a article in w3m (CLI pager with html render support)
export def open_article_in_w3m [
	article  # a article from `atom_feed parse`
] {
	let mime = (
		{  # fix some content-type descriptors not understood by w3m
			'html': 'text/html'
		}
		| get -i $article.content_type
		| default $article.content_type
	)
	$article.content | w3m -T $mime -title=$article.title
}
