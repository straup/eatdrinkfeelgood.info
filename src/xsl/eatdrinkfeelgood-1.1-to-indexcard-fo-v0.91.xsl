<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:e="http://www.eatdrinkfeelgood.info/1.1/ns"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                version="1.0">

<!-- ====================================================================== 
     eatdrinkfeelgood-1.1-to-indexcard-fo.xsl                                                   

     This stylesheet converts a recipe document conforming to the 
     eatdrinkfeelgood 1.1 DTD into an XSL-FO document suitable for generating 
     an index card.

     Version : 0.91
     Date    : $Date: 2003/01/01 23:36:40 $

     Copyright (c) 2002 Aaron Straup Cope
     http://www.eatdrinkfeelgood.info

     Documentation: http://www.eatdrinkfeelgood.info/tools/xsl/edfg-1.1-to-indexcard-fo

     Permission to use, copy, modify and distribute this stylesheet and its 
     accompanying documentation for any purpose and without fee is hereby 
     granted in perpetuity, provided that the above copyright notice and 
     this paragraph appear in all copies.  The copyright holders make no 
     representation about the suitability of the stylesheet for any purpose.

     It is provided "as is" without expressed or implied warranty.
     ====================================================================== -->

     <xsl:output method="xml" encoding = "UTF-8" indent = "yes" />

<!-- ====================================================================== 

     ====================================================================== -->

     <xsl:param name = "size" select = "large" />

<!-- ====================================================================== 

     ====================================================================== -->

     <xsl:key name = "extrefs" match = "//*[@xlink:href]"  use = "@xlink:href" />

<!-- ====================================================================== 

     ====================================================================== -->

     <xsl:template match="/">
      <fo:root>
       <fo:layout-master-set>

        <fo:simple-page-master>
         <xsl:attribute name = "master-name">default-odd</xsl:attribute>
         <xsl:call-template name = "fo:simple-page-master_shared" />

         <xsl:call-template name = "fo:region-body_default" />
         <xsl:call-template name = "fo:region-after_default-after" />
        </fo:simple-page-master>

        <fo:simple-page-master>
         <xsl:attribute name = "master-name">default-even</xsl:attribute>
         <xsl:attribute name = "reference-orientation">180</xsl:attribute>
         <xsl:call-template name = "fo:simple-page-master_shared" />
 
         <xsl:call-template name = "fo:region-body_default" />
         <xsl:call-template name = "fo:region-after_default-after" />
        </fo:simple-page-master>

        <fo:simple-page-master>
         <xsl:attribute name = "master-name">first</xsl:attribute>
         <xsl:call-template name = "fo:simple-page-master_shared" />

         <fo:region-body>
          <xsl:attribute name = "region-name">xsl-region-body</xsl:attribute>
          <xsl:attribute name = "margin-top">0.6in</xsl:attribute>
          <xsl:attribute name = "column-count">2</xsl:attribute>
         </fo:region-body>       

         <fo:region-before>
          <xsl:attribute name = "region-name">first-before</xsl:attribute>
          <xsl:attribute name = "extent">0.5in</xsl:attribute>
         </fo:region-before>
            
        </fo:simple-page-master>

        <!-- -->

        <fo:page-sequence-master>
         <xsl:attribute name = "master-name">recipe</xsl:attribute>
         <fo:repeatable-page-master-alternatives>
          <fo:conditional-page-master-reference>
           <xsl:attribute name = "master-reference">first</xsl:attribute>
           <xsl:attribute name = "page-position">first</xsl:attribute>
          </fo:conditional-page-master-reference>
          <fo:conditional-page-master-reference>
           <xsl:attribute name = "master-reference">default-odd</xsl:attribute>
           <xsl:attribute name = "odd-or-even">even</xsl:attribute>
           <xsl:attribute name = "page-position">rest</xsl:attribute>
          </fo:conditional-page-master-reference>
          <fo:conditional-page-master-reference>
           <xsl:attribute name = "master-reference">default-odd</xsl:attribute>
           <xsl:attribute name = "odd-or-even">odd</xsl:attribute>
           <xsl:attribute name = "page-position">rest</xsl:attribute>
          </fo:conditional-page-master-reference>
         </fo:repeatable-page-master-alternatives>
        </fo:page-sequence-master>

       </fo:layout-master-set>

       <!-- -->

       <fo:page-sequence master-reference="recipe">

        <fo:static-content>
         <xsl:attribute name = "flow-name">first-before</xsl:attribute>
         <fo:block>
          <xsl:call-template name = "fo:static-content-block_shared" />
          <xsl:attribute name = "border-bottom-color">black</xsl:attribute>
          <xsl:attribute name = "border-bottom-style">solid</xsl:attribute>
           <fo:block>
            <xsl:attribute name = "font-size">18pt</xsl:attribute>
            <xsl:value-of select = "e:eatdrinkfeelgood/e:recipe/e:name/e:common" /> 
           </fo:block>

           <xsl:variable name = "count" select = "count(e:eatdrinkfeelgood/e:recipe/e:name/e:other)" />

          <fo:block>
           <xsl:call-template name = "fo:block-attrs_h3" />
           <xsl:for-each select = "e:eatdrinkfeelgood/e:recipe/e:name/e:other">
            <xsl:value-of select = "." />
            <xsl:if test = "position() &lt; $count">,</xsl:if>
           </xsl:for-each>
          </fo:block>          

         </fo:block>
        </fo:static-content>

       <!-- -->

        <fo:static-content>
         <xsl:attribute name = "flow-name">default-after</xsl:attribute>
         <fo:block>
          <xsl:call-template name = "fo:static-content-block_shared" />
          <xsl:attribute name = "border-top-color">black</xsl:attribute>
          <xsl:attribute name = "border-top-style">solid</xsl:attribute>
          <xsl:attribute name = "border-after-width">1mm</xsl:attribute>            
          <xsl:attribute name = "padding-before">4pt</xsl:attribute>
          <xsl:value-of select = "e:eatdrinkfeelgood/e:recipe/e:name/e:common" /> /<fo:page-number />
         </fo:block>
        </fo:static-content>

        <!-- -->

        <fo:flow>
         <xsl:attribute name = "flow-name">xsl-region-body</xsl:attribute>
         <fo:block>
          <xsl:attribute name = "font-family">serif</xsl:attribute>
          <xsl:attribute name = "font-size">8pt</xsl:attribute>

          <fo:block>
           <xsl:attribute name = "break-after">column</xsl:attribute>              
           <xsl:attribute name = "start-indent">2mm</xsl:attribute>

           <xsl:apply-templates select = "/e:eatdrinkfeelgood/e:recipe/e:requirements/e:time" />           

           <xsl:apply-templates select = "/e:eatdrinkfeelgood/e:recipe/e:yield" />

           <xsl:apply-templates select = "e:eatdrinkfeelgood/e:recipe/e:source" />

           <xsl:if test = "/e:eatdrinkfeelgood/e:recipe/e:history">
            <xsl:apply-templates select = "/e:eatdrinkfeelgood/e:recipe/e:history" />             
           </xsl:if>

          </fo:block>
            
          <fo:block>
           <xsl:attribute name = "break-after">column</xsl:attribute>
           <xsl:apply-templates select = "/e:eatdrinkfeelgood/e:recipe/e:requirements/e:ingredients" />
           <xsl:apply-templates select = "/e:eatdrinkfeelgood/e:recipe/e:requirements/e:equipment" />
          </fo:block>

          <xsl:apply-templates select = "/e:eatdrinkfeelgood/e:recipe/e:directions" />

          <fo:block>
           <xsl:apply-templates select = "/e:eatdrinkfeelgood/e:recipe/e:notes" />
           <xsl:call-template name = "External-References" />
          </fo:block>

         </fo:block>
        </fo:flow>
       </fo:page-sequence>

      </fo:root>
     </xsl:template>

<!-- ======================================================================

     abstract
     ====================================================================== -->

     <xsl:template match = "e:abstract">
       <xsl:apply-templates select = "e:para" />
     </xsl:template>

<!-- ======================================================================

     amount
     ====================================================================== -->

     <xsl:template match = "e:amount">
      <xsl:apply-templates select = "e:quantity" />&#160;

      <xsl:choose>
       <xsl:when test = "e:measure/e:unit">
        <xsl:value-of select = "e:measure/e:unit/@content" />&#160;
       </xsl:when>        
       <xsl:otherwise>
        <xsl:if test = "string(e:measure/e:customunit)">
         <xsl:value-of select = "e:measure/e:customunit" />&#160;
        </xsl:if>       
       </xsl:otherwise>
      </xsl:choose>
      
      <xsl:apply-templates select = "e:detail" />
     </xsl:template>

<!-- ======================================================================

     author
     ====================================================================== -->

     <xsl:template match = "e:author">
      <xsl:apply-templates select = "e:extref" />         
     </xsl:template>

<!-- ======================================================================

     cooking
     ====================================================================== -->

     <xsl:template match = "e:cooking">
      <fo:block>
       <xsl:apply-templates />, <fo:inline font-style = "italic">cooking</fo:inline>         
      </fo:block>
     </xsl:template>

<!-- ======================================================================

     course
     ====================================================================== -->

     <xsl:template match = "e:course">
       <fo:block>

       <fo:block><xsl:apply-templates select = "e:name" /></fo:block>
       <xsl:apply-templates select = "e:abstract" />

       <fo:block style = "font-size:.8em;">
        <xsl:for-each select = "./*">
         <xsl:choose>
          <xsl:when test = "name()='recipe'">
           <xsl:apply-templates select = "." />
          </xsl:when>        
          <xsl:when test = "name()='xi:include'">
           <fo:block><xsl:apply-templates select = "." /></fo:block>
          </xsl:when>        
          <xsl:otherwise />    
          </xsl:choose>

        </xsl:for-each>
       </fo:block>

       <xsl:apply-templates select = "e:notes" />
     </fo:block>
     </xsl:template>

<!-- ======================================================================

     date
     ====================================================================== -->

     <xsl:template match = "dc:date">
      <xsl:value-of select = "." />
     </xsl:template>

<!-- ======================================================================

     days
     ====================================================================== -->

     <xsl:template match = "e:days">
      <xsl:value-of select = "e:n/@value" /> days
     </xsl:template>

<!-- ======================================================================

     detail
     ====================================================================== -->

     <xsl:template match = "e:detail">
      <fo:inline
       font-style = "italic">
       <xsl:value-of select = "." />
      </fo:inline>
     </xsl:template>

<!-- ======================================================================

     directions
     ====================================================================== -->

     <xsl:template match = "e:directions">
       <fo:block>
        <xsl:call-template name = "fo:block-attrs_sect" />         

       <fo:block>
        <xsl:call-template name = "fo:block-attrs_header" />         
         Directions
       </fo:block>

       <xsl:choose>
        <xsl:when test = "name(./*[position()=1]) = 'step'">
         <xsl:call-template name = "Steps" />
        </xsl:when>
        <xsl:otherwise>
         <xsl:apply-templates select = "e:stage" />
        </xsl:otherwise>
       </xsl:choose>

      </fo:block>

     </xsl:template>

<!-- ======================================================================

     equipment
     ====================================================================== -->

     <xsl:template match = "e:equipment">
       <fo:block>
        <xsl:call-template name = "fo:block-attrs_sect" />

       <fo:block>
        <xsl:call-template name = "fo:block-attrs_header" />
        Equipment
       </fo:block>
 
       <fo:list-block>
        <xsl:for-each select = "e:device">
        <fo:list-item>
          <fo:list-item-label>
           <xsl:call-template name = "fo:list-block-label_dot" />
          </fo:list-item-label>
         <fo:list-item-body>
          <fo:block><xsl:apply-templates /></fo:block>              
         </fo:list-item-body>
        </fo:list-item>
        </xsl:for-each>
       </fo:list-block>

      </fo:block>
     </xsl:template>

<!-- ======================================================================

     extref
     ====================================================================== -->

     <xsl:template match = "e:extref">
       
      <xsl:value-of select = "@xlink:title" />

        <xsl:call-template name = "Reference-Link">
          <xsl:with-param name = "uri">
            <xsl:value-of select = "@xlink:href" />
          </xsl:with-param>
        </xsl:call-template>

     </xsl:template>

<!-- ======================================================================

     history
     ====================================================================== -->

     <xsl:template match = "e:history">
      <fo:block>
       <xsl:attribute name = "space-before">5mm</xsl:attribute>
       <xsl:attribute name = "start-indent">5mm</xsl:attribute>
       <xsl:attribute name = "end-indent">5mm</xsl:attribute>
       <xsl:attribute name = "color">#666</xsl:attribute>            
       <xsl:attribute name = "font-style">italic</xsl:attribute>
       <xsl:attribute name = "text-align">justify</xsl:attribute>

       <xsl:apply-templates select = "e:para" />
       <fo:block>
        <xsl:call-template name = "fo:block-attrs_h3" />
        <xsl:attribute name = "font-style">normal</xsl:attribute>
        <xsl:apply-templates select = "e:author" />
       </fo:block>

      </fo:block>
     </xsl:template>

<!-- ======================================================================

     hours
     ====================================================================== -->

     <xsl:template match = "e:hours">
      <xsl:value-of select = "e:n/@value" /> hours
     </xsl:template>

<!-- ======================================================================

     image
     ====================================================================== -->

     <xsl:template match = "e:image">
     </xsl:template>

<!-- ======================================================================

     ingredients
     ====================================================================== -->

     <xsl:template match = "e:ingredients">
      <fo:block>
       <xsl:call-template name = "fo:block-attrs_sect" />         

       <fo:block>
        <xsl:call-template name = "fo:block-attrs_header" />
        Ingredients
       </fo:block>

        <!-- this is returning the count of all the ing element 
             rather than a count of unique ing/item; to be fixed -->

       <fo:block>
        <xsl:attribute name = "space-after">8pt</xsl:attribute>

        <xsl:variable name = "num-ings" select = "count(ancestor-or-self::*//e:ing)" />

        <xsl:for-each select = "ancestor-or-self::*//e:ing[count(.|key('ings', e:item)[1]) = 1]">
         <xsl:sort select="e:item" data-type="text" order="ascending"/>
         <xsl:value-of select = "e:item" /> 
         <xsl:if test = "position() &lt; $num-ings">, </xsl:if>
        </xsl:for-each>
       </fo:block>

       <xsl:choose>
        <xsl:when test = "name(./*[position()=1]) = 'ing'">
         <xsl:call-template name = "IngList" />
        </xsl:when>
        <xsl:otherwise>
         <xsl:apply-templates select = "e:set" />
        </xsl:otherwise>
       </xsl:choose>

      </fo:block>

     </xsl:template>

<!-- ======================================================================

     item
     ====================================================================== -->

     <xsl:template match = "item">
      <fo:inline>
       <xsl:value-of select = "item" />
      </fo:inline>
     </xsl:template>

<!-- ======================================================================

     menu
     ====================================================================== -->

     <xsl:template match = "e:menu" />

<!-- ======================================================================

     min
     ====================================================================== -->

     <xsl:template match = "e:min">
      <xsl:apply-templates select = "e:n" />
     </xsl:template>

<!-- ======================================================================

     minutes
     ====================================================================== -->

     <xsl:template match = "e:minutes">
      <xsl:value-of select = "e:n/@value" /> minutes
     </xsl:template>

<!-- ======================================================================

     max
     ====================================================================== -->

     <xsl:template match = "e:max">
      <xsl:apply-templates select = "e:n" />
     </xsl:template>

<!-- ====================================================================== 

     n
     ====================================================================== -->

     <xsl:template match = "e:n">
      <fo:inline>
       <xsl:value-of select = "@value" />
      </fo:inline>
     </xsl:template>

<!-- ======================================================================

     name
     ====================================================================== -->

     <xsl:template match = "e:name" />

<!-- ======================================================================

     note
     ====================================================================== -->

     <xsl:template match = "e:note">
      <fo:block>
       <xsl:apply-templates select = "e:para" />
       <fo:block>
        <xsl:call-template name = "fo:block-attrs_h3" />
        <xsl:attribute name = "text-align">left</xsl:attribute>
        <xsl:apply-templates select = "e:author" />
        <xsl:text> </xsl:text>
        <xsl:apply-templates select = "dc:date" />
       </fo:block>
      </fo:block>  
     </xsl:template>

<!-- ======================================================================

     notes
     ====================================================================== -->

     <xsl:template match = "e:notes">
      <fo:block>
       <xsl:call-template name = "fo:block-attrs_sect" />         

      <fo:block>
       <xsl:call-template name = "fo:block-attrs_header" />         
       Notes
      </fo:block>

      <fo:list-block>
       <xsl:for-each select = "e:note">
        <fo:list-item>
         <fo:list-item-label>
           <fo:block /> 
         </fo:list-item-label>
         <fo:list-item-body start-indent = "2mm">
          <fo:block>
           <xsl:apply-templates select = "." />
          </fo:block>              
         </fo:list-item-body>
        </fo:list-item>          
       </xsl:for-each>
      </fo:list-block>

      </fo:block>

     </xsl:template>

<!-- ======================================================================

     other
     ====================================================================== -->

     <xsl:template match = "e:other">
      <fo:inline
        font-style = "italic">
        <xsl:value-of select = "." />
      </fo:inline>
     </xsl:template>

<!-- ======================================================================

     para
     ====================================================================== -->

     <xsl:template match = "e:para">
      <fo:block>
       <xsl:attribute name = "space-after">4pt</xsl:attribute>
       <xsl:value-of select = "." />
      </fo:block>
     </xsl:template>

<!-- ======================================================================

     publication
     ====================================================================== -->

     <xsl:template match = "e:publication">

      <xsl:value-of select = "e:name" />

        <xsl:if test = "@xlink:href">
        <xsl:call-template name = "Reference-Link">
          <xsl:with-param name = "uri">
            <xsl:value-of select = "@xlink:href" />
          </xsl:with-param>
        </xsl:call-template>
        </xsl:if>

        <xsl:if test = "@isbn">
         <fo:block>
          <xsl:value-of select = "@isbn" />
         </fo:block>
        </xsl:if>

     </xsl:template>

<!-- ======================================================================

     preparation
     ====================================================================== -->

     <xsl:template match = "e:preparation">
      <fo:block>      
       <xsl:apply-templates />
       <xsl:text>, </xsl:text>
       <fo:inline>
        <xsl:attribute name = "font-style">italic</xsl:attribute>
        preparation
       </fo:inline> 
       </fo:block>
     </xsl:template>

<!-- ======================================================================

     quantity
     ====================================================================== -->

     <xsl:template match = "e:quantity">
      <xsl:choose>
       <xsl:when test = "e:range">
        <xsl:apply-templates select = "e:range" />
       </xsl:when>
       <xsl:otherwise>
        <xsl:apply-templates select = "e:n" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:template>

<!-- ======================================================================

     range
     ====================================================================== -->

     <xsl:template match = "e:range">
      <xsl:apply-templates select = "e:min" />-<xsl:apply-templates select = "e:max" />
     </xsl:template>

<!-- ====================================================================== 

     requirements
     ====================================================================== -->

     <xsl:template match = "e:requirements" />

<!-- ====================================================================== 

     set
     ====================================================================== -->

     <xsl:template match = "e:set">
      <fo:block>
       <xsl:call-template name = "fo:block-attrs_sect2" /> 

       <fo:block>
        <xsl:call-template name = "fo:block-attrs_h3" />
        <xsl:value-of select = "e:name/e:common" />
       </fo:block>

       <xsl:choose>
        <xsl:when test = "xi:include">
        <fo:list-block>
         <xsl:for-each select = "xi:include">
          <fo:list-item>
          <fo:list-item-label>
           <xsl:call-template name = "fo:list-block-label_dot" />
          </fo:list-item-label>
          <fo:list-item-body>
           <fo:block>
            <xsl:apply-templates select = "." />
           </fo:block>
         </fo:list-item-body>              
          </fo:list-item>
         </xsl:for-each>
         </fo:list-block>
        </xsl:when>
        <xsl:otherwise>
         <xsl:call-template name = "IngList" />           
        </xsl:otherwise>
       </xsl:choose>
       </fo:block>

     </xsl:template>

<!-- ====================================================================== 

     source
     ====================================================================== -->

     <xsl:template match = "e:source">
      <fo:block>
       <xsl:call-template name = "fo:block-attrs_sect" />

       <fo:block>
        <xsl:call-template name = "fo:block-attrs_header" />
        Source
       </fo:block>

       <fo:block>
        <xsl:apply-templates select = "e:publication" />
       </fo:block>

       <fo:block>
        <xsl:if test = "e:publication">
         <xsl:attribute name = "space-before">0.5em</xsl:attribute>           
        </xsl:if>

        <xsl:variable name = "count" select = "count(e:author)" />
        <xsl:for-each select = "e:author">
         <xsl:apply-templates select = "." />
        <xsl:if test = "position() &lt; $count">, </xsl:if>
        </xsl:for-each>
       </fo:block>

      </fo:block>

     </xsl:template>

<!-- ====================================================================== 

     stage
     ====================================================================== -->

     <xsl:template match = "e:stage">
      <fo:block>
       <xsl:attribute name = "start-indent">2mm</xsl:attribute>
  
       <fo:block>
        <xsl:call-template name = "fo:block-attrs_h3" />
        <xsl:value-of select = "e:name/e:common" />           
       </fo:block>
  
       <xsl:choose>
        <xsl:when test = "xi:include">
         <fo:list-block>
         <xsl:for-each select = "xi:include">
         <fo:list-item>
          <fo:list-item-label>
           <xsl:call-template name = "fo:list-block-label_dot" />
          </fo:list-item-label>
         <fo:list-item-body>
          <fo:block><xsl:apply-templates /></fo:block>              
         </fo:list-item-body>
        </fo:list-item>
         </xsl:for-each>
         </fo:list-block>
        </xsl:when>
        <xsl:otherwise>
         <xsl:call-template name = "Steps" />
        </xsl:otherwise>
       </xsl:choose>
      </fo:block>
     </xsl:template>

<!-- ====================================================================== 

     time
     ====================================================================== -->

     <xsl:template match = "e:time">
      <fo:block>
       <xsl:call-template name = "fo:block-attrs_sect" />

      <fo:block>
       <xsl:call-template name = "fo:block-attrs_header" />
       Time
      </fo:block>
      <fo:block>
       <xsl:call-template name = "fo:block-attrs_sect" />
       <xsl:apply-templates select = "e:preparation" />
       <xsl:apply-templates select = "e:cooking" />
      </fo:block>
     </fo:block>
     </xsl:template>

<!-- ====================================================================== 

     xi:include
     ====================================================================== -->

     <xsl:template match = "xi:include">
      <fo:inline>
       <xsl:call-template name = "style-emphasize" />
       see :
      </fo:inline>
      <xsl:apply-templates />
     </xsl:template>

<!-- ====================================================================== 

     yield
     ====================================================================== -->

     <xsl:template match = "e:yield">
      <fo:block>
       <xsl:call-template name = "fo:block-attrs_sect" />

      <fo:block>
        <xsl:call-template name = "fo:block-attrs_header" />
        Yield
       </fo:block>

       <xsl:for-each select = "e:amount">
        <fo:block>
         <xsl:apply-templates />
        </fo:block>
       </xsl:for-each>

      </fo:block>
     </xsl:template>

     <xsl:template name = "External-References">

      <fo:block>
       <xsl:call-template name = "fo:block-attrs_sect" />         

      <fo:block>
       <xsl:call-template name = "fo:block-attrs_header" />         
        External References
      </fo:block>

       <fo:list-block>
        <xsl:call-template name = "footnote-body" />

        <xsl:for-each select = "//*[name() = 'extref' or name() = 'publication'][count(.|key('extrefs', @xlink:href)[1]) = 1]">
        <fo:list-item>
          <fo:list-item-label>
           <fo:block>
             <xsl:call-template name = "footnote-label" />
             <xsl:value-of select = "position()" />.
           </fo:block>
         </fo:list-item-label>
         <fo:list-item-body>
           <fo:block>
            <xsl:call-template name = "footnote-content" />
            <xsl:value-of select = "@xlink:href" />
           </fo:block>
         </fo:list-item-body>
       </fo:list-item>
        </xsl:for-each>
      </fo:list-block>

    </fo:block>

     </xsl:template>

     <xsl:template name = "Reference-Link">
      <xsl:param name = "uri" />
      <xsl:for-each select = "//*[name() = 'extref' or name() = 'publication'][count(.|key('extrefs', @xlink:href)[1]) = 1]">       
       <xsl:if test = "$uri = @xlink:href">
         <fo:inline>
          <xsl:text>  </xsl:text>
          [<fo:character>
           <xsl:call-template name = "footnote-marker" />
           <xsl:attribute name = "character">
            <xsl:value-of select = "position()" />
           </xsl:attribute>
          </fo:character>]
         </fo:inline>
       </xsl:if>
      </xsl:for-each>
     </xsl:template>

<!-- ====================================================================== 

     IngList
     ====================================================================== -->

     <xsl:template name = "IngList">
      <fo:list-block>
       <xsl:for-each select = "e:ing">
        <fo:list-item>
          <fo:list-item-label>
           <xsl:call-template name = "fo:list-block-label_dot" />
          </fo:list-item-label>
          <fo:list-item-body start-indent = "5mm">
           <fo:block>
            <xsl:apply-templates select = "." />
           </fo:block>
         </fo:list-item-body>              
        </fo:list-item> 
      </xsl:for-each>
      </fo:list-block>
     </xsl:template>

<!-- ====================================================================== 

     Steps
     ====================================================================== -->

     <xsl:template name = "Steps">
       <fo:list-block>
        <xsl:attribute name = "space-before">6pt</xsl:attribute>

       <xsl:for-each select = "e:step">
        <fo:list-item>
          <fo:list-item-label>
           <fo:block><xsl:value-of select = "position()" />.</fo:block>
          </fo:list-item-label>
          <fo:list-item-body start-indent = "5mm">
           <fo:block>
            <xsl:apply-templates select = "." />
           </fo:block>
         </fo:list-item-body>              
        </fo:list-item> 
       </xsl:for-each>
     </fo:list-block>
     </xsl:template>

     <xsl:template name = "page-height">
      <xsl:choose>
       <xsl:when test = "$size = 'small'">4in</xsl:when>
       <xsl:otherwise>5in</xsl:otherwise>
      </xsl:choose>
     </xsl:template>

     <xsl:template name = "page-width">
      <xsl:choose>
       <xsl:when test = "$size = 'small'">6in</xsl:when>
       <xsl:otherwise>7in</xsl:otherwise>
      </xsl:choose>
     </xsl:template>

     <xsl:template name = "margin-left-right">
      <xsl:choose>
       <xsl:when test = "$size = 'small'">0.25in</xsl:when>
       <xsl:otherwise>0.5in</xsl:otherwise>
      </xsl:choose>
     </xsl:template>

     <xsl:template name = "fo:simple-page-master_shared">
      <xsl:attribute name = "page-height"><xsl:call-template name = "page-height" /></xsl:attribute>
      <xsl:attribute name = "page-width"><xsl:call-template name = "page-width" /></xsl:attribute>
      <xsl:attribute name = "margin-top">0.5in</xsl:attribute>
      <xsl:attribute name = "margin-bottom">0.5in</xsl:attribute>
      <xsl:attribute name = "margin-left"><xsl:call-template name = "margin-left-right" /></xsl:attribute>
      <xsl:attribute name = "margin-right"><xsl:call-template name = "margin-left-right" /></xsl:attribute>
     </xsl:template>

     <xsl:template name = "fo:static-content-block_shared">
      <xsl:attribute name = "font-family">sans-serif</xsl:attribute>
      <xsl:attribute name = "font-size">8pt</xsl:attribute>
      <xsl:attribute name = "text-align">right</xsl:attribute>
     </xsl:template>

     <xsl:template name = "fo:block-attrs_sect">
      <xsl:attribute name = "space-after">3pt</xsl:attribute>
     </xsl:template>

     <xsl:template name = "fo:block-attrs_sect2">
      <xsl:attribute name = "start-indent">2mm</xsl:attribute>
      <xsl:attribute name = "space-after">3pt</xsl:attribute>
     </xsl:template>

     <xsl:template name = "fo:block-attrs_header">
      <xsl:attribute name = "font-family">sans-serif</xsl:attribute>
      <xsl:attribute name = "font-weight">bold</xsl:attribute>
      <xsl:attribute name = "space-after">4pt</xsl:attribute>
     </xsl:template>

     <xsl:template name = "fo:block-attrs_h3">
      <xsl:attribute name = "font-family">sans-serif</xsl:attribute>
      <xsl:attribute name = "font-size">7pt</xsl:attribute>
      <xsl:attribute name = "space-after">4pt</xsl:attribute>
      <xsl:attribute name = "color">#ccc</xsl:attribute>
      <xsl:attribute name = "text-align">right</xsl:attribute>
      <!-- not yet implemented by Fop, 20021227 
      <xsl:attribute name = "text-transform">lowercase</xsl:attribute>-->
     </xsl:template>

     <xsl:template name = "footnote-marker">
      <xsl:attribute name = "font-size">6pt</xsl:attribute>
      <xsl:attribute name = "baseline-shift">super</xsl:attribute>
     </xsl:template>

     <xsl:template name = "footnote-body">
      <xsl:attribute name = "start-indent">0em</xsl:attribute>
      <xsl:attribute name = "font-family">sans-serif</xsl:attribute>
      <xsl:attribute name = "font-size">6pt</xsl:attribute>
      <xsl:attribute name = "text-align">left</xsl:attribute>
      <xsl:attribute name = "color">#000</xsl:attribute>
     </xsl:template>

     <xsl:template name = "footnote-label">
     </xsl:template>

     <xsl:template name = "footnote-content">
      <xsl:attribute name = "start-indent">1.5em</xsl:attribute>
     </xsl:template>

     <xsl:template name = "fo:list-block-label_dot">
      <fo:block>
       <fo:inline>
        <xsl:attribute name = "font-family">Symbol</xsl:attribute>
        <xsl:attribute name = "color">#ccc</xsl:attribute>
        &#x2022;
       </fo:inline>
      </fo:block>       
     </xsl:template>

     <xsl:template name = "fo:region-body_default">
      <fo:region-body>
       <xsl:attribute name = "region-name">xsl-region-body</xsl:attribute>
       <xsl:attribute name = "margin-bottom">0.5in</xsl:attribute>
       <xsl:attribute name = "column-count">2</xsl:attribute>
      </fo:region-body>       
     </xsl:template>

     <xsl:template name = "fo:region-after_default-after">
         <fo:region-after>
          <xsl:attribute name = "region-name">default-after</xsl:attribute>
          <xsl:attribute name = "extent">0.25in</xsl:attribute>
         </fo:region-after>
       
     </xsl:template>

     <xsl:template name = "style-emphasize">
      <xsl:attribute name = "font-style">italic</xsl:attribute>
     </xsl:template>

     <xsl:template name = "footnote-number">
      <xsl:number count = "//*[@xlink:href]" level = "any" format = "1" />
     </xsl:template>

<!-- ======================================================================
     FIN
     ====================================================================== -->

</xsl:stylesheet>
