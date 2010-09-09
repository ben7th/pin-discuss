class BlueCloth < String
  def transform_headers( str, rs )
		@log.debug " Transforming headers"

		str.
			gsub( AtxHeaderRegexp ) {|m|
      @log.debug "Found ATX-style header"
      hdrchars, title = $1, $2
      title = apply_span_transforms( title, rs )

      level = hdrchars.length
      %{<h%d>%s</h%d>\n\n} % [ level, title, level ]
    }
	end

  def form_paragraphs( str, rs )
		@log.debug " Forming paragraphs"
		grafs = str.
			sub( /\A\n+/, '' ).
			sub( /\n+\z/, '' ).
			split( /\n{1,}/ )

		rval = grafs.collect {|graf|

			# Unhashify HTML blocks if this is a placeholder
			if rs.html_blocks.key?( graf )
				rs.html_blocks[ graf ]

        # Otherwise, wrap in <p> tags
			else
				apply_span_transforms(graf, rs).
					sub( /^[ ]*/, '<p>' ) + '</p>'
			end
		}.join( "\n\n" )

		@log.debug " Formed paragraphs: %p" % rval
		return rval
	end
end