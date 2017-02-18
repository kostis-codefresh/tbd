#!/bin/sh

function normalize_index_file_names {
  grep -rl "$1" . | xargs sed -i '' "s#$1\"#$1index.html\"#g"
}

function extract_just_the_article {

  echo "<html><head></head><body>$(xidel --html $1index.html --extract "//article")</body></html>" >  "$1index.html"
  perl -pi -e 's/<!DOCTYPE html>//' "$1index.html"
  perl -pi -e 's/<aside/<aside style="display: none"/' "$1index.html"
  perl -pi -e 's/<footer/<footer style="display: none"/' "$1index.html"

  # change videos to links to videos
  cat $1index.html | sed '/<div noprint/d' | sponge $1index.html
  cat $1index.html | sed 's/<!-- print //' | sponge $1index.html
  cat $1index.html | sed 's/ print -->//' | sponge $1index.html

  if [ "$2" = true ] ; then
    perl -pi -e "s#href=\"/#href=\"../#g" "$1index.html"
    perl -pi -e "s#src=\"/#src=\"../#g" "$1index.html"
    perl -pi -e "s#url\(/images/LogoSlim#url\(../images/LogoSlim#g" "$1index.html"
  else
    perl -pi -e "s#href=\"/#href=\"#g" "$1index.html"
    perl -pi -e "s#src=\"/#src=\"#g" "$1index.html"
    perl -pi -e "s#url\(/images/LogoSlim#url\(images/LogoSlim#g" "$1index.html"
  fi
}

function normalize_index_file_names_and_extract_just_the_article {
  if [ "$2" = true ] ; then
    normalize_index_file_names $1
  fi
  extract_just_the_article $1 $2
}

hugo -d tempHugo

cd tempHugo

find . -name "*.xml" -print0 | xargs -0 rm -rf

normalize_index_file_names_and_extract_just_the_article 5-min-overview/ true
normalize_index_file_names_and_extract_just_the_article alternative-branching-models/ true
normalize_index_file_names_and_extract_just_the_article branch-by-abstraction/ true
normalize_index_file_names_and_extract_just_the_article branch-for-release/ true
normalize_index_file_names_and_extract_just_the_article concurrent-development-of-consecutive-releases/ true
normalize_index_file_names_and_extract_just_the_article context/ true
normalize_index_file_names_and_extract_just_the_article continuous-delivery/ true
normalize_index_file_names_and_extract_just_the_article continuous-integration/ true
normalize_index_file_names_and_extract_just_the_article continuous-review/ true
normalize_index_file_names_and_extract_just_the_article deciding-factors/ true
normalize_index_file_names_and_extract_just_the_article expanding-contracting-monorepos/ true
normalize_index_file_names_and_extract_just_the_article feature-flags/ true
normalize_index_file_names_and_extract_just_the_article game-changers/ true
normalize_index_file_names_and_extract_just_the_article monorepos/ true
normalize_index_file_names_and_extract_just_the_article monorepos/ true
normalize_index_file_names_and_extract_just_the_article observed-habits/ true
normalize_index_file_names_and_extract_just_the_article publications/ true
normalize_index_file_names_and_extract_just_the_article release-from-trunk/ true
normalize_index_file_names_and_extract_just_the_article strangulation/ true
normalize_index_file_names_and_extract_just_the_article vcs-choices/ true
normalize_index_file_names_and_extract_just_the_article youre-doing-it-wrong/ true

# Table of contents gets inserted once (was on every page)
PBDT=$(git log | head -n 3 | grep Date | tr -s ' ' | cut -d ' ' -f2-12)
echo "<html><body>$(xidel --html index.html --extract "//div[@class='drawer']")<br/>Book transformation of <a href='https://trunkbaseddevelopment.com'>TrunkBasedDevelopment.com</a><br/>Copyright &copy; 2017: Paul Hammant and Steve Smith<br/>This book is free (gratis) to copy as long as you don't modify it, otherwise your owe us \$1,000,000 USD<br/>Generated $PBDT <br/></body></html>" >  "toc.html"
perl -pi -e 's/<!DOCTYPE html>//' toc.html
perl -pi -e 's/<aside/<aside style="display: none"/' toc.html
perl -pi -e "s#href=\"/#href=\"#g" toc.html
perl -pi -e "s#src=\"/#src=\"#g" toc.html

normalize_index_file_names_and_extract_just_the_article "" false

ebook-convert toc.html ../trunk_based_development_book.pdf --page-breaks-before "//h:h1" --breadth-first --publisher=trunkbaseddevelopment.com --language=es --title "Trunk Based Development" --authors "Paul Hammant & Steve Smith" --pubdate "$PBDT" --cover ../book_cover.jpg

rm -rf tempHugo/