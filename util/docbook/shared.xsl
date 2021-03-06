<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:saxon="http://icl.com/saxon" xmlns:exsl="http://exslt.org/common"
    xmlns:db="http://docbook.org/ns/docbook" xmlns:d="http://docbook.org/ns/docbook"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
    xmlns:xtbl="xalan://com.nwalsh.xalan.Table" xmlns:lxslt="http://xml.apache.org/xslt"
    xmlns:ptbl="http://nwalsh.com/xslt/ext/xsltproc/python/Table"
    xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="doc stbl xtbl lxslt ptbl d saxon db exsl xlink">
    
    <!-- NOTE:
            Namespaces are stripped in the markup that gets processed, but by grabbing the top info
            block here you get the namespaced markup. What that means is any call to apply-templates that
            expects to use the default transforms will fail. Use value-of or write your own transforms.
            Future fix is to find a better way to get at the info block and remove this port for them
            old transform.
            -->
    
    <!-- release info -->
    <xsl:variable name="topinfo" select="//db:info[1]"/>
    <xsl:variable name="toptitle" select="//db:title[1]"/>
    
    <!-- add xml:lang/lang to root -->
    <xsl:template name="root.attributes">
        <xsl:if test="string-length(normalize-space(@xml:lang)) &gt; 0">
            <xsl:copy-of select="@xml:lang"/>
            <xsl:attribute name="lang">
                <xsl:value-of select="@xml:lang"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    
    <!-- remove status from table of contents -->
    <xsl:template match="preface[@id='sotd']"  mode="toc" />
    
    <!-- ============================================================================= -->
    <!-- crude rearrange of the leading info element to structure as an IDPF spec document  -->
    <xsl:template name="book.titlepage">

        <xsl:element name="header" namespace="http://www.w3.org/1999/xhtml">
            
            <!-- logo -->
            <xsl:element name="p">
                <xsl:element name="a">
                    <xsl:attribute name="href">http://www.idpf.org</xsl:attribute>
                    <xsl:element name="img">
                        <xsl:attribute name="src">../../images/idpflogo_web_125.jpg</xsl:attribute>
                        <xsl:attribute name="class">logo</xsl:attribute>
                        <xsl:attribute name="alt">IDPF</xsl:attribute>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            
            <!-- title -->
            <xsl:element name="h1" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class">title</xsl:attribute>
                <xsl:value-of select="$toptitle"/>
            </xsl:element>
            
            <xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class">identity</xsl:attribute>
                <xsl:if test="$topinfo/db:releaseinfo[not(@role)]">
                    <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                        <xsl:attribute name="class">releaseinfo</xsl:attribute>
                        <xsl:value-of select="$topinfo/db:releaseinfo[not(@role)]"/>
                    </xsl:element>
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="class">pubdate</xsl:attribute>
                    <xsl:value-of select="$topinfo/db:pubdate"/>
                </xsl:element>
            </xsl:element>
            
            <!-- history -->
            <xsl:if test="$topinfo/db:printhistory">
                <xsl:element name="dl" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="class">printhistory</xsl:attribute>
                    <xsl:for-each select="$topinfo/db:printhistory/db:formalpara">
                        <xsl:element name="dt" namespace="http://www.w3.org/1999/xhtml">
                            <xsl:value-of select="current()/db:title"/>
                        </xsl:element>
                        <xsl:element name="dd" namespace="http://www.w3.org/1999/xhtml">
                            <xsl:choose>
                                <xsl:when test="current()/db:para/db:link">
                                    <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="current()/db:para/db:link/@xlink:href"/>
                                        </xsl:attribute>
                                        <xsl:value-of select="current()/db:para/db:link/@xlink:href"/>
                                    </xsl:element>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="current()/db:para"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:element>
            </xsl:if>
            
            <!-- diff -->
            
            <xsl:element name="div">
                <xsl:attribute name="class">history</xsl:attribute>
                <xsl:element name="span">
                    <xsl:attribute name="class">history-title</xsl:attribute>
                    <xsl:text>Document history</xsl:text>
                </xsl:element>
                <xsl:element name="ul">
                    <xsl:element name="li">
                        <xsl:apply-templates select="$topinfo/db:releaseinfo[@role='history']/node()"/>
                    </xsl:element>
                    <xsl:element name="li">
                        <xsl:element name="a">
                            <xsl:attribute name="href">https://github.com/IDPF/epub-revision/issues?q=milestone%3A%22EPUB+3.1%22+is%3Aclosed</xsl:attribute>
                            <xsl:text>Issues addressed in this revision</xsl:text>
                        </xsl:element>
                    </xsl:element>
                    <xsl:element name="li">
                        <xsl:element name="a">
                            <xsl:attribute name="href">https://github.com/IDPF/epub-revision/issues</xsl:attribute>
                            <xsl:text>Report an issue</xsl:text>
                        </xsl:element>
                    </xsl:element>
                    <xsl:if test="$topinfo/db:releaseinfo[@role='errata']">
                        <xsl:element name="li">
                            <xsl:apply-templates select="$topinfo/db:releaseinfo[@role='errata']/node()"/>
                        </xsl:element>
                    </xsl:if>
                </xsl:element>
            </xsl:element>
            
            <!-- editors -->
            <xsl:if test="$topinfo/db:authorgroup[not(@role) or @role='current']">
                <xsl:call-template name="render-authorgroup">
                    <xsl:with-param name="title">Editors</xsl:with-param>
                    <xsl:with-param name="node"
                        select="$topinfo/db:authorgroup[not(@role) or @role='current']"/>
                </xsl:call-template>
            </xsl:if>
            <!-- authors -->
            <xsl:if test="$topinfo/db:authorgroup[@role='authors']">
                <xsl:call-template name="render-authorgroup">
                    <xsl:with-param name="title">Authors</xsl:with-param>
                    <xsl:with-param name="node"
                        select="$topinfo/db:authorgroup[@role='authors']"/>
                </xsl:call-template>
            </xsl:if>
            
            <xsl:if test="$topinfo/db:releaseinfo[@role='formats']">
                <xsl:element name="p">
                    <xsl:attribute name="class">formats</xsl:attribute>
                    <xsl:apply-templates select="$topinfo/db:releaseinfo[@role='formats']/node()"/>
                </xsl:element>
            </xsl:if>
            
            <!-- copyright -->
            <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class">legalnotice</xsl:attribute>
                <xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:text>Copyright © </xsl:text>
                    <xsl:value-of select="$topinfo/db:copyright"/>
                </xsl:element>
                <xsl:apply-templates mode="book.titlepage.recto.mode" select="$topinfo/db:legalnotice"/>
            </xsl:element>
        </xsl:element>

        <!-- status -->
        <xsl:if test="preface[@id='sotd']">
            <xsl:element name="section">
                <xsl:attribute name="id">sotd</xsl:attribute>
                <xsl:element name="h2">Status of this Document</xsl:element>
                <xsl:apply-templates select="preface[@id='sotd']/*[not(self::title)]"/>
            </xsl:element>
        </xsl:if>
        <!--
        <xsl:if test="$topinfo/authorgroup[@role='previous']">
            <xsl:call-template name="render-authorgroup">
                <xsl:with-param name="title">Editors (previous versions)</xsl:with-param>
                <xsl:with-param name="node" select="$topinfo/authorgroup[@role='previous']"/>
            </xsl:call-template>
        </xsl:if>
        -->
    	<xsl:if test="$topinfo/db:abstract[@role='informative-label']">
    		<xsl:element name="div">
    			<xsl:attribute name="class">doc-label</xsl:attribute>
    		    <xsl:apply-templates select="$topinfo/db:abstract[@role='informative-label']/*"/>
    		</xsl:element>
    	</xsl:if>
    </xsl:template>
    
    <xsl:template match="db:para[ancestor::db:info]" priority="1">
        <xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="db:link[ancestor::db:info]" priority="1">
        <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="href">
                <xsl:value-of select="@xlink:href"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="string-length(normalize-space(.)) &gt; 0">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@xlink:href"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="preface[@id='sotd']" priority="1"/>
    
    <xsl:template name="render-authorgroup">
        <xsl:param name="title"/>
        <xsl:param name="node"/>
        <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">authorgroup</xsl:attribute>
            <xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class">bridgehead</xsl:attribute>
                <xsl:value-of select="$title"/>
            </xsl:element>
            <xsl:for-each select="$node/db:editor|$node/db:author">
                <xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:apply-templates select="." mode="class.attribute"/>
                    <xsl:choose>
                        <xsl:when test="db:orgname">
                            <xsl:value-of select="db:orgname"/>
                        </xsl:when>
                        <xsl:when test="db:personname and db:affiliation">
                            <xsl:value-of select="db:personname"/>, <xsl:value-of
                                select="db:affiliation"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="person.name"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
   </xsl:template>

    <!-- ============================================================================= -->
    <!-- overrides in html.xsl to get @id on elements instead of in child anchor -->

    <xsl:template name="anchor">

        <!-- This is the template that we typically override and dont execute in order
            to get IDs directly on elements instead of child anchors. There's a couple 
            of exceptions due to exceedingly messy underlying xslt, and we also use this
            template to conditionally add the "Link Here" feature. 
        
            The templates used for id-on-element follow immediately after this one.
        -->

        <xsl:param name="node" select="."/>
        <xsl:param name="conditional" select="1"/>
        <xsl:variable name="id">
            <xsl:call-template name="object.id">
                <xsl:with-param name="object" select="$node"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- for cals tables, there's no way to reasonably override table.xsl#entry|entrytbl -->
        <xsl:if
            test="(local-name($node) = 'production' or local-name($node) = 'constraintdef' or
                    local-name($node) = 'entry' or local-name($node) = 'tgroup') and $node/@id">
            <xsl:attribute name="id">
                <xsl:value-of select="$id"/>
            </xsl:attribute>
        </xsl:if>

        <!-- link here anchor -->

        <xsl:variable name="is-conformance-list-para"
            select="ancestor::*[@role='conformance-list'] and local-name(.) = 'para' and string-length($id) > 0"/>

        <xsl:variable name="parentName" select="local-name(..)"/>

        <xsl:variable name="is-section"
            select="$node[title] and ($parentName='section' or $parentName='book' or $parentName='chapter' or $parentName='appendix') and string-length($id) > 0"/>

        <xsl:if test="$conditional = 0 or $node/@id">
            <xsl:if test="$is-section or $is-conformance-list-para">
                <xsl:call-template name="render-link-here-anchor">
                    <xsl:with-param name="id" select="$id"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>

        <!-- match the headers in the property cals tables -->
        <xsl:if test="local-name($node) = 'literal' and parent::entry[@role='rdfa-property']">
            <xsl:call-template name="render-link-here-anchor">
                <xsl:with-param name="id" select="../@id"/>
            </xsl:call-template>
        </xsl:if>

    </xsl:template>

    <xsl:template name="render-link-here-anchor">
        <xsl:param name="id"/>
        <xsl:element name="span">
            <xsl:attribute name="class">link-marker</xsl:attribute>
            <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class">hidden-reveal</xsl:attribute>
                <xsl:attribute name="href">#<xsl:value-of select="$id"/></xsl:attribute>
                <xsl:text disable-output-escaping="no">&#160;</xsl:text>
            </xsl:element>
            <xsl:text disable-output-escaping="no">&#160;</xsl:text>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*" mode="common.html.attributes" priority="1">
        <xsl:param name="class" select="local-name(.)"/>
        <xsl:param name="inherit" select="0"/>

        <xsl:apply-imports>
            <xsl:with-param name="class" select="$class"/>
            <xsl:with-param name="inherit" select="$inherit"/>
        </xsl:apply-imports>

        <xsl:variable name="id">
            <xsl:call-template name="object.id">
                <xsl:with-param name="object" select="."/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:if test="./@id">
            <xsl:attribute name="id">
                <xsl:value-of select="$id"/>
            </xsl:attribute>
        </xsl:if>

    </xsl:template>

    <xsl:template match="*" mode="locale.html.attributes" priority="1">
        <xsl:apply-imports/>
        <xsl:apply-templates select="." mode="common.html.attributes"/>
    </xsl:template>

    <!-- override to add @id to element instead of child anchor -->
    <xsl:template match="glossentry" priority="1">
        <xsl:element name="dt" namespace="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates select="." mode="common.html.attributes"/>
            <xsl:choose>
                <xsl:when test="$glossentry.show.acronym = 'primary'">
                    <xsl:call-template name="anchor">
                        <xsl:with-param name="conditional">
                            <xsl:choose>
                                <xsl:when test="$glossterm.auto.link != 0">0</xsl:when>
                                <xsl:otherwise>1</xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:choose>
                        <xsl:when test="acronym|abbrev">
                            <xsl:apply-templates select="acronym|abbrev"/>
                            <xsl:text> (</xsl:text>
                            <xsl:apply-templates select="glossterm"/>
                            <xsl:text>)</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="glossterm"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$glossentry.show.acronym = 'yes'">
                    <xsl:call-template name="anchor">
                        <xsl:with-param name="conditional">
                            <xsl:choose>
                                <xsl:when test="$glossterm.auto.link != 0">0</xsl:when>
                                <xsl:otherwise>1</xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:apply-templates select="glossterm"/>
                    <xsl:if test="acronym|abbrev">
                        <xsl:text> (</xsl:text>
                        <xsl:apply-templates select="acronym|abbrev"/>
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="anchor">
                        <xsl:with-param name="conditional">
                            <xsl:choose>
                                <xsl:when test="$glossterm.auto.link != 0">0</xsl:when>
                                <xsl:otherwise>1</xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:apply-templates select="glossterm"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
        <xsl:apply-templates select="indexterm|revhistory|glosssee|glossdef"/>
    </xsl:template>

    <!-- ==================================================================== -->
    <!-- override to add @id to element instead of child anchor -->
    <xsl:template match="varlistentry" priority="1">
        <xsl:element name="dt" namespace="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates select="." mode="common.html.attributes"/>
            <xsl:call-template name="anchor"/>
            <xsl:apply-templates select="term"/>
        </xsl:element>
        <xsl:element name="dd" namespace="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates select="listitem"/>
        </xsl:element>
    </xsl:template>

    <!-- ==================================================================== -->
    <!-- override to add @id to element instead of child anchor -->

    <xsl:template name="informal.object">
        <xsl:param name="class" select="local-name(.)"/>
        <xsl:variable name="content">
            <xsl:element name="div">
                <xsl:apply-templates select="." mode="common.html.attributes"/>
                <xsl:if test="$spacing.paras != 0">
                    <p/>
                </xsl:if>
                <xsl:call-template name="anchor"/>
                <xsl:apply-templates/>
                <xsl:if test="local-name(.) = 'informaltable'">
                    <xsl:call-template name="table.longdesc"/>
                </xsl:if>
                <xsl:if test="$spacing.paras != 0">
                    <p/>
                </xsl:if>
            </xsl:element>
        </xsl:variable>
        <xsl:variable name="floatstyle">
            <xsl:call-template name="floatstyle"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$floatstyle != ''">
                <xsl:call-template name="floater">
                    <xsl:with-param name="class"><xsl:value-of select="$class"
                        />-float</xsl:with-param>
                    <xsl:with-param name="floatstyle" select="$floatstyle"/>
                    <xsl:with-param name="content" select="$content"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$content"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ==================================================================== -->
    <!-- override to add @id to element instead of child anchor -->

    <xsl:template name="formal.object">
        <xsl:param name="placement" select="'before'"/>
        <xsl:param name="class">
            <xsl:apply-templates select="." mode="class.value"/>
        </xsl:param>

        <xsl:call-template name="id.warning"/>

        <xsl:variable name="content">
            <xsl:element name="div">
                <xsl:attribute name="class">
                    <xsl:value-of select="$class"/>
                </xsl:attribute>
                <xsl:apply-templates select="." mode="common.html.attributes"/>

                <xsl:call-template name="anchor">
                    <xsl:with-param name="conditional" select="0"/>
                </xsl:call-template>

                <xsl:choose>
                    <xsl:when test="$placement = 'before'">
                        <xsl:call-template name="formal.object.heading"/>
                        <div class="{$class}-contents">
                            <xsl:apply-templates/>
                        </div>
                        <!-- HACK: This doesn't belong inside formal.object; it 
                            should be done by the table template, but I want 
                            the link to be inside the DIV, so... -->
                        <xsl:if test="local-name(.) = 'table'">
                            <xsl:call-template name="table.longdesc"/>
                        </xsl:if>

                        <xsl:if test="$spacing.paras != 0">
                            <p/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="$spacing.paras != 0">
                            <p/>
                        </xsl:if>
                        <div class="{$class}-contents">
                            <xsl:apply-templates/>
                        </div>
                        <!-- HACK: This doesn't belong inside formal.object; it 
                            should be done by the table template, but I want 
                            the link to be inside the DIV, so... -->
                        <xsl:if test="local-name(.) = 'table'">
                            <xsl:call-template name="table.longdesc"/>
                        </xsl:if>

                        <xsl:call-template name="formal.object.heading"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
            <xsl:if test="not($formal.object.break.after = '0')">
                <br class="{$class}-break"/>
            </xsl:if>
        </xsl:variable>

        <xsl:variable name="floatstyle">
            <xsl:call-template name="floatstyle"/>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$floatstyle != ''">
                <xsl:call-template name="floater">
                    <xsl:with-param name="class"><xsl:value-of select="$class"
                        />-float</xsl:with-param>
                    <xsl:with-param name="floatstyle" select="$floatstyle"/>
                    <xsl:with-param name="content" select="$content"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$content"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- ============================================================================= -->
    <!-- end of id and template related templates (see also htmlTableAtt below though -->
    <!-- ============================================================================= -->


    <!-- ============================================================================= -->
    <!-- override in html.xsl to set preference order for creating a class value -->

    <xsl:template match="*" mode="class.value" priority="1">
        <xsl:param name="class" select="local-name(.)"/>
        <xsl:choose>
            <xsl:when test="@xrefstyle">
                <xsl:value-of select="@xrefstyle"/>
            </xsl:when>
            <xsl:when test="@role">
                <xsl:value-of select="@role"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$class"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- ============================================================================= -->
    <!-- override titlepage hr separators -->

    <xsl:template name="book.titlepage.separator"/>
    <xsl:template name="section.titlepage.separator"/>


    <!-- change div to nav and add id to toc -->
    <xsl:template name="make.toc">
        <xsl:param name="toc-context" select="."/>
        <xsl:param name="toc.title.p" select="true()"/>
        <xsl:param name="nodes" select="/NOT-AN-ELEMENT"/>
        
        <xsl:variable name="nodes.plus" select="$nodes | qandaset"/>
        
        <xsl:variable name="toc.title">
            <xsl:if test="$toc.title.p">
                <xsl:choose>
                    <xsl:when test="$make.clean.html != 0">
                        <h2 class="toc-title">
                            <xsl:call-template name="gentext">
                                <xsl:with-param name="key">TableofContents</xsl:with-param>
                            </xsl:call-template>
                        </h2>
                    </xsl:when>
                    <xsl:otherwise>
                        <p>
                            <strong xmlns:xslo="http://www.w3.org/1999/XSL/Transform">
                                <xsl:call-template name="gentext">
                                    <xsl:with-param name="key">TableofContents</xsl:with-param>
                                </xsl:call-template>
                            </strong>
                        </p>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$manual.toc != ''">
                <xsl:variable name="id">
                    <xsl:call-template name="object.id"/>
                </xsl:variable>
                <xsl:variable name="toc" select="document($manual.toc, .)"/>
                <xsl:variable name="tocentry" select="$toc//tocentry[@linkend=$id]"/>
                <xsl:if test="$tocentry and $tocentry/*">
                    <div class="toc">
                        <xsl:copy-of select="$toc.title"/>
                        <xsl:element name="{$toc.list.type}" namespace="http://www.w3.org/1999/xhtml">
                            <xsl:call-template name="toc.list.attributes">
                                <xsl:with-param name="toc-context" select="$toc-context"/>
                                <xsl:with-param name="toc.title.p" select="$toc.title.p"/>
                                <xsl:with-param name="nodes" select="$nodes"/>
                            </xsl:call-template>
                            <xsl:call-template name="manual-toc">
                                <xsl:with-param name="tocentry" select="$tocentry/*[1]"/>
                            </xsl:call-template>
                        </xsl:element>
                    </div>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$qanda.in.toc != 0">
                        <xsl:if test="$nodes.plus">
                            <div class="toc">
                                <xsl:copy-of select="$toc.title"/>
                                <xsl:element name="{$toc.list.type}" namespace="http://www.w3.org/1999/xhtml">
                                    <xsl:call-template name="toc.list.attributes">
                                        <xsl:with-param name="toc-context" select="$toc-context"/>
                                        <xsl:with-param name="toc.title.p" select="$toc.title.p"/>
                                        <xsl:with-param name="nodes" select="$nodes"/>
                                    </xsl:call-template>
                                    <xsl:apply-templates select="$nodes.plus" mode="toc">
                                        <xsl:with-param name="toc-context" select="$toc-context"/>
                                    </xsl:apply-templates>
                                </xsl:element>
                            </div>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="$nodes">
                            <nav class="toc" id="toc">
                                <xsl:copy-of select="$toc.title"/>
                                <xsl:element name="{$toc.list.type}" namespace="http://www.w3.org/1999/xhtml">
                                    <xsl:call-template name="toc.list.attributes">
                                        <xsl:with-param name="toc-context" select="$toc-context"/>
                                        <xsl:with-param name="toc.title.p" select="$toc.title.p"/>
                                        <xsl:with-param name="nodes" select="$nodes"/>
                                    </xsl:call-template>
                                    <xsl:apply-templates select="$nodes" mode="toc">
                                        <xsl:with-param name="toc-context" select="$toc-context"/>
                                    </xsl:apply-templates>
                                </xsl:element>
                            </nav>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- fix biblio to section -->
    <xsl:template match="bibliography" priority="1">
        <xsl:call-template name="id.warning"/>
        
        <section>
            <xsl:call-template name="common.html.attributes">
                <xsl:with-param name="inherit" select="1"/>
            </xsl:call-template>
            <xsl:call-template name="id.attribute">
                <xsl:with-param name="conditional" select="0"/>
            </xsl:call-template>
            
            <xsl:call-template name="bibliography.titlepage"/>
            
            <xsl:apply-templates/>
            
            <xsl:if test="not(parent::article)">
                <xsl:call-template name="process.footnotes"/>
            </xsl:if>
        </section>
    </xsl:template>
    
    
    
    
    <!-- ============================================================================= -->
    <!-- remark[@role='todo'] ==> span[@class='todo'] -->
    <!-- Note:  template copied from inline.xsl and modified -->
    <xsl:template match="remark[@role='todo']" priority="1">
        <xsl:param name="content">
            <xsl:call-template name="anchor"/>
            <xsl:call-template name="simple.xlink">
                <xsl:with-param name="content">
                    <xsl:apply-templates/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:param>
        <!-- * if you want output from the inline.charseq template wrapped in -->
        <!-- * something other than a Span, call the template with some value -->
        <!-- * for the 'wrapper-name' param -->
        <xsl:param name="wrapper-name">span</xsl:param>
        <xsl:if test="$show.comments != 0">
            <xsl:element name="{$wrapper-name}" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class">todo</xsl:attribute>
                <xsl:call-template name="dir"/>
                <xsl:call-template name="generate.html.title"/>
                <xsl:copy-of select="$content"/>
                <xsl:call-template name="apply-annotations"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!-- ============================================================================= -->
    <!-- Fill in the docbook placeholder user.head.content template to add an http-equiv meta
        element (helps IE < 9) -->

    <xsl:template name="user.head.content">
        <xsl:element name="meta" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="charset">utf-8</xsl:attribute>
        </xsl:element>
        <xsl:element name="link">
            <xsl:attribute name="rel">stylesheet</xsl:attribute>
            <xsl:attribute name="href">
                <xsl:value-of select="$user.print.css"/>
            </xsl:attribute>
            <xsl:attribute name="type">text/css</xsl:attribute>
            <xsl:attribute name="media">print</xsl:attribute>
        </xsl:element>
    </xsl:template>

    <!-- ============================================================================= -->
    <!-- For chapters, preface, sections, and appendices that have @conformance, add a "This section is ..." line -->
    <!-- We match on title so that we can insert the text after the heading -->
    
    <xsl:template name="section.title">
        <!-- the context node should be the title of a section when called -->
        <xsl:variable name="section" select="(ancestor::section                                         |ancestor::simplesect                                         |ancestor::sect1                                         |ancestor::sect2                                         |ancestor::sect3                                         |ancestor::sect4                                         |ancestor::sect5)[last()]"/>
        
        <xsl:variable name="renderas">
            <xsl:choose>
                <xsl:when test="$section/@renderas = 'sect1'">1</xsl:when>
                <xsl:when test="$section/@renderas = 'sect2'">2</xsl:when>
                <xsl:when test="$section/@renderas = 'sect3'">3</xsl:when>
                <xsl:when test="$section/@renderas = 'sect4'">4</xsl:when>
                <xsl:when test="$section/@renderas = 'sect5'">5</xsl:when>
                <xsl:otherwise><xsl:value-of select="''"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="level">
            <xsl:choose>
                <xsl:when test="$renderas != ''">
                    <xsl:value-of select="$renderas"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="section.level">
                        <xsl:with-param name="node" select="$section"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:call-template name="section.heading">
            <xsl:with-param name="section" select="$section"/>
            <xsl:with-param name="level" select="$level"/>
            <xsl:with-param name="title">
                <xsl:apply-templates select="$section" mode="object.title.markup">
                    <xsl:with-param name="allow-anchors" select="1"/>
                </xsl:apply-templates>
            </xsl:with-param>
        </xsl:call-template>
        
        <xsl:variable name="conformanceLevel" select="../@conformance"/>
        <xsl:variable name="parentName" select="local-name(..)"/>
        
        <xsl:variable name="structureName">
            <xsl:choose>
                <xsl:when
                    test="$parentName='preface' or $parentName='chapter' or $parentName='bibliography'">
                    <xsl:text>section</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$parentName"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$conformanceLevel != ''">
            <xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class">
                    <xsl:value-of select="$conformanceLevel"/>
                </xsl:attribute> This <xsl:value-of select="$structureName"/> is <xsl:value-of
                    select="$conformanceLevel"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    

    <!-- ============================================================================= -->
    <!-- add templates as per htmltbl.xsl in order to get id and role -->

    <xsl:template mode="htmlTableAtt" match="@role" priority="1">
        <xsl:attribute name="class">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>


    <!-- ============================================================================= -->
    <!-- override title page templates to remove all the excess divs -->


    <xsl:template name="book.titlepage-nomatch">
        <xsl:variable name="recto.content">
            <xsl:call-template name="book.titlepage.before.recto"/>
            <xsl:call-template name="book.titlepage.recto"/>
        </xsl:variable>
        <xsl:variable name="recto.elements.count">
            <xsl:choose>
                <xsl:when test="function-available('exsl:node-set')">
                    <xsl:value-of select="count(exsl:node-set($recto.content)/*)"/>
                </xsl:when>
                <xsl:when
                    test="contains(system-property('xsl:vendor'), 'Apache Software Foundation')">
                    <!--Xalan quirk-->
                    <xsl:value-of select="count(exsl:node-set($recto.content)/*)"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="(normalize-space($recto.content) != '') or ($recto.elements.count &gt; 0)">
            <xsl:copy-of select="$recto.content"/>
        </xsl:if>
        <xsl:variable name="verso.content">
            <xsl:call-template name="book.titlepage.before.verso"/>
            <xsl:call-template name="book.titlepage.verso"/>
        </xsl:variable>
        <xsl:variable name="verso.elements.count">
            <xsl:choose>
                <xsl:when test="function-available('exsl:node-set')">
                    <xsl:value-of select="count(exsl:node-set($verso.content)/*)"/>
                </xsl:when>
                <xsl:when
                    test="contains(system-property('xsl:vendor'), 'Apache Software Foundation')">
                    <!--Xalan quirk-->
                    <xsl:value-of select="count(exsl:node-set($verso.content)/*)"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="(normalize-space($verso.content) != '') or ($verso.elements.count &gt; 0)">
            <xsl:copy-of select="$verso.content"/>
        </xsl:if>
        <xsl:call-template name="book.titlepage.separator"/>
    </xsl:template>

    <xsl:template match="title" mode="book.titlepage.recto.auto.mode" priority="1">
        <xsl:apply-templates select="." mode="book.titlepage.recto.mode"/>
    </xsl:template>

    <xsl:template match="title" mode="chapter.titlepage.recto.auto.mode" priority="1">
        <xsl:apply-templates select="." mode="chapter.titlepage.recto.mode"/>
    </xsl:template>

    <xsl:template match="title" mode="section.titlepage.recto.auto.mode" priority="1">
        <xsl:apply-templates select="." mode="section.titlepage.recto.mode"/>
    </xsl:template>

    <xsl:template name="chapter.titlepage">
        <xsl:variable name="recto.content">
            <xsl:call-template name="chapter.titlepage.before.recto"/>
            <xsl:call-template name="chapter.titlepage.recto"/>
        </xsl:variable>
        <xsl:variable name="recto.elements.count">
            <xsl:choose>
                <xsl:when test="function-available('exsl:node-set')">
                    <xsl:value-of select="count(exsl:node-set($recto.content)/*)"/>
                </xsl:when>
                <xsl:when
                    test="contains(system-property('xsl:vendor'), 'Apache Software Foundation')">
                    <!--Xalan quirk-->
                    <xsl:value-of select="count(exsl:node-set($recto.content)/*)"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="(normalize-space($recto.content) != '') or ($recto.elements.count &gt; 0)">
            <xsl:copy-of select="$recto.content"/>
        </xsl:if>
        <xsl:variable name="verso.content">
            <xsl:call-template name="chapter.titlepage.before.verso"/>
            <xsl:call-template name="chapter.titlepage.verso"/>
        </xsl:variable>
        <xsl:variable name="verso.elements.count">
            <xsl:choose>
                <xsl:when test="function-available('exsl:node-set')">
                    <xsl:value-of select="count(exsl:node-set($verso.content)/*)"/>
                </xsl:when>
                <xsl:when
                    test="contains(system-property('xsl:vendor'), 'Apache Software Foundation')">
                    <!--Xalan quirk-->
                    <xsl:value-of select="count(exsl:node-set($verso.content)/*)"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="(normalize-space($verso.content) != '') or ($verso.elements.count &gt; 0)">
            <xsl:copy-of select="$verso.content"/>
        </xsl:if>
        <xsl:call-template name="chapter.titlepage.separator"/>
    </xsl:template>

    <!-- ============================================================================= -->
    <!-- override section title page templates to remove all the excess divs and correct heading levels -->

    <xsl:template name="section.titlepage">

        <xsl:variable name="recto.content">
            <xsl:call-template name="section.titlepage.before.recto"/>
            <xsl:call-template name="section.titlepage.recto"/>
        </xsl:variable>
        <xsl:variable name="recto.elements.count">
            <xsl:choose>
                <xsl:when test="function-available('exsl:node-set')">
                    <xsl:value-of select="count(exsl:node-set($recto.content)/*)"/>
                </xsl:when>
                <xsl:when
                    test="contains(system-property('xsl:vendor'), 'Apache Software Foundation')">
                    <!--Xalan quirk-->
                    <xsl:value-of select="count(exsl:node-set($recto.content)/*)"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="(normalize-space($recto.content) != '') or ($recto.elements.count &gt; 0)">
            <xsl:copy-of select="$recto.content"/>
        </xsl:if>
        <xsl:variable name="verso.content">
            <xsl:call-template name="section.titlepage.before.verso"/>
            <xsl:call-template name="section.titlepage.verso"/>
        </xsl:variable>
        <xsl:variable name="verso.elements.count">
            <xsl:choose>
                <xsl:when test="function-available('exsl:node-set')">
                    <xsl:value-of select="count(exsl:node-set($verso.content)/*)"/>
                </xsl:when>
                <xsl:when
                    test="contains(system-property('xsl:vendor'), 'Apache Software Foundation')">
                    <!--Xalan quirk-->
                    <xsl:value-of select="count(exsl:node-set($verso.content)/*)"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="(normalize-space($verso.content) != '') or ($verso.elements.count &gt; 0)">
            <xsl:copy-of select="$verso.content"/>
        </xsl:if>
        <xsl:call-template name="section.titlepage.separator"/>

    </xsl:template>

    <!-- ==================================================================== -->
    <!-- fix bug that allows h7+ for bridgeheads -->
    <xsl:template match="bridgehead" priority="1">
        <xsl:variable name="container" select="(ancestor::acknowledgements                         |ancestor::appendix                         |ancestor::article                         |ancestor::bibliography                         |ancestor::chapter                         |ancestor::glossary                         |ancestor::glossdiv                         |ancestor::index                         |ancestor::partintro                         |ancestor::preface                         |ancestor::refsect1                         |ancestor::refsect2                         |ancestor::refsect3                         |ancestor::sect1                         |ancestor::sect2                         |ancestor::sect3                         |ancestor::sect4                         |ancestor::sect5                         |ancestor::section                         |ancestor::setindex                         |ancestor::simplesect)[last()]"/>
        
        <xsl:variable name="clevel">
            <xsl:choose>
                <xsl:when test="local-name($container) = 'appendix'                       or local-name($container) = 'chapter'                       or local-name($container) = 'article'                       or local-name($container) = 'bibliography'                       or local-name($container) = 'glossary'                       or local-name($container) = 'index'                       or local-name($container) = 'partintro'                       or local-name($container) = 'preface'                       or local-name($container) = 'setindex'">1</xsl:when>
                <xsl:when test="local-name($container) = 'glossdiv'">
                    <xsl:value-of select="count(ancestor::glossdiv)+1"/>
                </xsl:when>
                <xsl:when test="local-name($container) = 'sect1'                       or local-name($container) = 'sect2'                       or local-name($container) = 'sect3'                       or local-name($container) = 'sect4'                       or local-name($container) = 'sect5'                       or local-name($container) = 'refsect1'                       or local-name($container) = 'refsect2'                       or local-name($container) = 'refsect3'                       or local-name($container) = 'section'                       or local-name($container) = 'simplesect'">
                    <xsl:variable name="slevel">
                        <xsl:call-template name="section.level">
                            <xsl:with-param name="node" select="$container"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:value-of select="$slevel + 1"/>
                </xsl:when>
                <xsl:when test="local-name($container) = 'acknowledgements'">
                    <xsl:choose>
                        <xsl:when test="@role='lvl3'">3</xsl:when>
                        <xsl:otherwise>2</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- HTML H level is one higher than section level -->
        <xsl:variable name="hlevel">
            <xsl:choose>
                <xsl:when test="@renderas = 'sect1'">2</xsl:when>
                <xsl:when test="@renderas = 'sect2'">3</xsl:when>
                <xsl:when test="@renderas = 'sect3'">4</xsl:when>
                <xsl:when test="@renderas = 'sect4'">5</xsl:when>
                <xsl:when test="@renderas = 'sect5'">6</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$clevel + 1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="maxlevel">
            <xsl:choose>
                <xsl:when test="$clevel &gt; 6">6</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$clevel"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:element name="h{$maxlevel}" namespace="http://www.w3.org/1999/xhtml">
            <xsl:call-template name="id.attribute">
                <xsl:with-param name="conditional" select="0"/>
            </xsl:call-template>
            <xsl:call-template name="anchor">
                <xsl:with-param name="conditional" select="0"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <!-- ==================================================================== -->
    <!-- remove code wrapping xrefs and links to fix whitespace problems -->

    <xsl:template match="code[@role='linkwrap']" priority="1">
        <xsl:apply-templates/>
    </xsl:template>



    <!-- ==================================================================== -->
    <!-- acknowledgements -->
    <xsl:template match="itemizedlist[@role='personlist']" priority="1">
        <ul>
            <xsl:apply-templates select="." mode="common.html.attributes"/>
            <xsl:for-each select="./listitem">
                <li class="person">
                    <span class="name">
                        <span class="surname">
                            <xsl:value-of select="current()//surname"/>
                        </span>
                        <xsl:text>, </xsl:text>
                        <span class="givenname">
                            <xsl:value-of select="current()//firstname"/>
                        </span>
                    </span>
                    <xsl:if test="current()//affiliation">
                        <xsl:text> </xsl:text>
                        <span class="affiliation">(<xsl:value-of select="current()//affiliation"
                            />)</span>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                    <xsl:if test="current()//jobtitle">
                        <xsl:text> </xsl:text>
                        <span class="wg-role">
                            <xsl:value-of select="current()//jobtitle"/>
                        </span>
                    </xsl:if>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>

    <!-- ==================================================================== -->
    <!-- ebnf -->

    <!-- override, to avoid nested table layout -->
    <xsl:template match="productionset" priority="1">
        <table>
            <xsl:attribute name="style">
                <xsl:text>width: 100%; border-spacing: 0; border-collapse: collapse;</xsl:text>
<!--
                <xsl:if test="$ebnf.table.bgcolor != ''">
                    <xsl:text>background-color: </xsl:text>
                    <xsl:value-of select="$ebnf.table.bgcolor"/>
                </xsl:if>
-->
            </xsl:attribute>
            <xsl:attribute name="class">
                <xsl:value-of select="local-name(.)"/>
            </xsl:attribute>
<!--            <xsl:attribute name="summary">
                <xsl:text>EBNF productions</xsl:text>
                <xsl:if test="title">
                    <xsl:text> for </xsl:text>
                    <xsl:value-of select="title"/>
                </xsl:if>
            </xsl:attribute> -->
            <caption>
                <xsl:text>(EBNF productions </xsl:text>
                <a
                    href="http://www.iso.org/iso/iso_catalogue/catalogue_tc/catalogue_detail.htm?csnumber=26153">
                    <xsl:text>ISO/IEC 14977</xsl:text>
                </a>
                <xsl:text>)</xsl:text>
            	<br/>
            	<xsl:text>All terminal symbols are in the Unicode Block 'Basic Latin' (U+0000 to U+007F).</xsl:text>
            </caption>
            <xsl:apply-templates select="production|productionrecap"/>
        </table>
    </xsl:template>

    <!-- td align="{$direction.align.start}" valign="top" width="3%">
            <xsl:text>[</xsl:text>
            <xsl:number count="production" level="any"/>
            <xsl:text>]</xsl:text>
            </td -->

    <xsl:template match="production" priority="1">
        <xsl:param name="recap" select="false()"/>
        <tr>
            <td style="text-align: {$direction.align.end}; vertical-align: top;">
                <xsl:choose>
                    <xsl:when test="$recap">
                        <a>
                            <xsl:attribute name="href">
                                <xsl:call-template name="href.target">
                                    <xsl:with-param name="object" select="."/>
                                </xsl:call-template>
                            </xsl:attribute>
                            <xsl:apply-templates select="lhs"/>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="anchor"/>
                        <xsl:apply-templates select="lhs"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <td style="vertical-align: top; text-align: center;">
                <xsl:copy-of select="$ebnf.assignment"/>
            </td>
            <td style="vertical-align: top">
                <xsl:apply-templates select="rhs"/>
                <xsl:copy-of select="$ebnf.statement.terminator"/>
            </td>
            <td style="vertical-align: top; text-align: {$direction.align.start};">
                <xsl:choose>
                    <xsl:when test="rhs/lineannotation|constraint">
                        <xsl:apply-templates select="rhs/lineannotation" mode="rhslo"/>
                        <xsl:apply-templates select="constraint"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>&#160;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </td>

        </tr>
    </xsl:template>
    <xsl:template match="lhs" priority="1">
        <a>
            <xsl:attribute name="href">
                <xsl:text>#</xsl:text>
                <xsl:value-of select="../@id"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </a>
    </xsl:template>
	
	
	<!-- Fixes ???TITLE??? output when bridgeheads have inline elements -->
	
	<xsl:template match="bridgehead" mode="title.markup" priority="1">
		<xsl:apply-templates/>
	</xsl:template>	
	
	<!-- convert rfc keywords to spans instead of code -->
	
    <xsl:template match="literal[@role]" priority="1">
		<xsl:element name="span">
		    <xsl:attribute name="class"><xsl:value-of select="@role"/></xsl:attribute>
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:template>
	
	<!-- remove the <a id=""/> in the legal notice that causes constantly 
		changing ids on all the specs with each build -->
	
    <xsl:template match="db:legalnotice" mode="titlepage.mode" priority="1">
		<xsl:variable name="id"><xsl:call-template name="object.id"/></xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$generate.legalnotice.link != 0">
				
				<!-- Compute name of legalnotice file -->
				<xsl:variable name="file">
					<xsl:call-template name="ln.or.rh.filename"/>
				</xsl:variable>
				
				<xsl:variable name="filename">
					<xsl:call-template name="make-relative-filename">
						<xsl:with-param name="base.dir" select="$base.dir"/>
						<xsl:with-param name="base.name" select="$file"/>
					</xsl:call-template>
				</xsl:variable>
				
				<xsl:variable name="title">
					<xsl:apply-templates select="." mode="title.markup"/>
				</xsl:variable>
				
				<a href="{$file}">
					<xsl:copy-of select="$title"/>
				</a>
				
				<xsl:call-template name="write.chunk">
					<xsl:with-param name="filename" select="$filename"/>
					<xsl:with-param name="quiet" select="$chunk.quietly"/>
					<xsl:with-param name="content">
						<xsl:call-template name="user.preroot"/>
						<html>
							<head>
								<xsl:call-template name="system.head.content"/>
								<xsl:call-template name="head.content"/>
								<xsl:call-template name="user.head.content"/>
							</head>
							<body>
								<xsl:call-template name="body.attributes"/>
								<div>
									<xsl:apply-templates select="." mode="common.html.attributes"/>
									<xsl:apply-templates mode="titlepage.mode"/>
								</div>
							</body>
						</html>
						<xsl:value-of select="$chunk.append"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<div>
					<xsl:apply-templates select="." mode="common.html.attributes"/>
					<xsl:apply-templates mode="titlepage.mode"/>
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
    
    <xsl:template match="markup" priority="1">
        <xsl:call-template name="inline.monoseq"/>
    </xsl:template>
    
    <xsl:template mode="htmlTableAtt" match="@id" priority="1">
        <xsl:if test="not(parent::informaltable) and not(parent::table)">
            <xsl:copy-of select="."/>
        </xsl:if>
    </xsl:template>
    
    
    <!-- generate indexes in section with conformance -->

    <xsl:template match="index" priority="1">
        <!-- some implementations use completely empty index tags to indicate -->
        <!-- where an automatically generated index should be inserted. so -->
        <!-- if the index is completely empty, skip it. Unless generate.index -->
        <!-- is non-zero, in which case, this is where the automatically -->
        <!-- generated index should go. -->
        
        <xsl:call-template name="id.warning"/>
        
        <xsl:variable name="conformanceLevel" select="@conformance"/>
        
        <xsl:if test="count(*)&gt;0 or $generate.index != '0'">
            <section>
                <xsl:apply-templates select="." mode="common.html.attributes"/>
                <xsl:call-template name="id.attribute">
                    <xsl:with-param name="conditional" select="0"/>
                </xsl:call-template>
                
                <xsl:call-template name="index.titlepage"/>
                
                <xsl:if test="$conformanceLevel != ''">
                    <xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
                        <xsl:attribute name="class">
                            <xsl:value-of select="$conformanceLevel"/>
                        </xsl:attribute> This index is <xsl:value-of select="$conformanceLevel"/>
                    </xsl:element>
                </xsl:if>
                
                <xsl:choose>
                    <xsl:when test="indexdiv">
                        <xsl:apply-templates/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="*[not(self::indexentry)]"/>
                        <!-- Because it's actually valid for Index to have neither any -->
                        <!-- Indexdivs nor any Indexentries, we need to check and make -->
                        <!-- sure that at least one Indexentry exists, and generate a -->
                        <!-- wrapper dl if there is at least one; otherwise, do nothing. -->
                        <xsl:if test="indexentry">
                            <!-- The indexentry template assumes a parent dl wrapper has -->
                            <!-- been generated; for Indexes that have Indexdivs, the dl -->
                            <!-- wrapper is generated by the indexdiv template; however, -->
                            <!-- for Indexes that lack Indexdivs, if we don't generate a -->
                            <!-- dl here, HTML output will not be valid. -->
                            <dl>
                                <xsl:apply-templates select="indexentry"/>
                            </dl>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:if test="count(indexentry) = 0 and count(indexdiv) = 0">
                    <xsl:call-template name="generate-index">
                        <xsl:with-param name="scope" select="(ancestor::book|/)[last()]"/>
                    </xsl:call-template>
                </xsl:if>
                
                <xsl:if test="not(parent::article)">
                    <xsl:call-template name="process.footnotes"/>
                </xsl:if>
            </section>
        </xsl:if>
    </xsl:template>
    
    
    <!-- stop ack from appearing at top of document -->
    
    <xsl:template match="book" priority="1">
        <xsl:call-template name="id.warning"/>
        
        <xsl:call-template name="book.titlepage"/>
        
        <xsl:apply-templates select="dedication" mode="dedication"/>
<!--        <xsl:apply-templates select="acknowledgements" mode="acknowledgements"/> -->
        
        <xsl:variable name="toc.params">
            <xsl:call-template name="find.path.params">
                <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:call-template name="make.lots">
            <xsl:with-param name="toc.params" select="$toc.params"/>
            <xsl:with-param name="toc">
                <xsl:call-template name="division.toc">
                    <xsl:with-param name="toc.title.p" select="contains($toc.params, 'title')"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
        
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="acknowledgements" priority="1">
        <xsl:apply-templates select="." mode="acknowledgements"/>
    </xsl:template>
    
    <xsl:template match="acknowledgements" mode="acknowledgements" priority="1">
        <xsl:call-template name="id.warning"/>
        
        <section>
            <xsl:call-template name="common.html.attributes">
                <xsl:with-param name="inherit" select="1"/>
            </xsl:call-template>
            <xsl:call-template name="id.attribute">
                <xsl:with-param name="conditional" select="0"/>
            </xsl:call-template>
            <xsl:call-template name="acknowledgements.titlepage"/>
            <xsl:apply-templates/>
            <xsl:call-template name="process.footnotes"/>
        </section>
    </xsl:template>
    
    <xsl:template name="acknowledgements.titlepage">
        <div class="titlepage">
            <xsl:variable name="recto.content">
                <xsl:call-template name="acknowledgements.titlepage.before.recto"/>
                <xsl:call-template name="acknowledgements.titlepage.recto"/>
            </xsl:variable>
            <xsl:variable name="recto.elements.count">
                <xsl:choose>
                    <xsl:when test="function-available('exsl:node-set')"><xsl:value-of select="count(exsl:node-set($recto.content)/*)"/></xsl:when>
                    <xsl:when test="contains(system-property('xsl:vendor'), 'Apache Software Foundation')">
                        <!--Xalan quirk--><xsl:value-of select="count(exsl:node-set($recto.content)/*)"/></xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="(normalize-space($recto.content) != '') or ($recto.elements.count &gt; 0)">
                <div><xsl:copy-of select="$recto.content"/></div>
            </xsl:if>
            <xsl:variable name="verso.content">
                <xsl:call-template name="acknowledgements.titlepage.before.verso"/>
                <xsl:call-template name="acknowledgements.titlepage.verso"/>
            </xsl:variable>
            <xsl:variable name="verso.elements.count">
                <xsl:choose>
                    <xsl:when test="function-available('exsl:node-set')"><xsl:value-of select="count(exsl:node-set($verso.content)/*)"/></xsl:when>
                    <xsl:when test="contains(system-property('xsl:vendor'), 'Apache Software Foundation')">
                        <!--Xalan quirk--><xsl:value-of select="count(exsl:node-set($verso.content)/*)"/></xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="(normalize-space($verso.content) != '') or ($verso.elements.count &gt; 0)">
                <div><xsl:copy-of select="$verso.content"/></div>
            </xsl:if>
            <xsl:call-template name="acknowledgements.titlepage.separator"/>
        </div>
        <xsl:variable name="conformanceLevel" select="@conformance"/>
        <xsl:if test="$conformanceLevel != ''">
            <xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
                <xsl:attribute name="class">
                    <xsl:value-of select="$conformanceLevel"/>
                </xsl:attribute> This section is <xsl:value-of select="$conformanceLevel"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    
    <xsl:template match="acknowledgements" mode="toc" priority="1">
        <xsl:element name="li" namespace="http://www.w3.org/1999/xhtml">
            <xsl:call-template name="toc.line"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="division.toc">
        <xsl:param name="toc-context" select="."/>
        <xsl:param name="toc.title.p" select="true()"/>
        
        <xsl:call-template name="make.toc">
            <xsl:with-param name="toc-context" select="$toc-context"/>
            <xsl:with-param name="toc.title.p" select="$toc.title.p"/>
            <xsl:with-param name="nodes" select="part|reference|preface|chapter|appendix|article|topic|bibliography|glossary|index|refentry|bridgehead[$bridgehead.in.toc != 0]|acknowledgements"/>
        </xsl:call-template>
    </xsl:template>
    
    
    <!-- format annotations as issues -->
    <xsl:template match="annotation" priority="1">
        <xsl:variable name="iCount" select="count(preceding::annotation)+1"/>
        <xsl:element name="div">
            <xsl:attribute name="class">issue</xsl:attribute>
            <xsl:element name="h6">
                <xsl:attribute name="id">issue-<xsl:value-of select="$iCount"/></xsl:attribute>
                OPEN ISSUE
                <xsl:value-of select="$iCount"/>
            </xsl:element>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <!-- override chapter to add conformance -->
    <xsl:template match="chapter">
        <xsl:call-template name="id.warning"/>
        
        <xsl:element name="{$div.element}" namespace="http://www.w3.org/1999/xhtml">
            <xsl:call-template name="common.html.attributes">
                <xsl:with-param name="inherit" select="1"/>
            </xsl:call-template>
            <xsl:call-template name="id.attribute">
                <xsl:with-param name="conditional" select="0"/>
            </xsl:call-template>
            
            <xsl:call-template name="component.separator"/>
            <xsl:call-template name="chapter.titlepage"/>
            
            <xsl:variable name="toc.params">
                <xsl:call-template name="find.path.params">
                    <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:if test="contains($toc.params, 'toc')">
                <xsl:call-template name="component.toc">
                    <xsl:with-param name="toc.title.p" select="contains($toc.params, 'title')"/>
                </xsl:call-template>
                <xsl:call-template name="component.toc.separator"/>
            </xsl:if>
            
            <xsl:variable name="conformanceLevel" select="@conformance"/>
            <xsl:if test="$conformanceLevel != ''">
                <xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:attribute name="class">
                        <xsl:value-of select="$conformanceLevel"/>
                    </xsl:attribute> This section is <xsl:value-of select="$conformanceLevel"/>
                </xsl:element>
            </xsl:if>
            
            <xsl:apply-templates/>
            <xsl:call-template name="process.footnotes"/>
        </xsl:element>
    </xsl:template>
    

</xsl:stylesheet>
