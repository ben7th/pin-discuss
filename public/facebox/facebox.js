/*
 * Facebox (for jQuery)
 * version: 1.2 (05/05/2008)
 * @requires jQuery v1.2 or later
 *
 * Examples at http://famspam.com/facebox/
 *
 * Licensed under the MIT:
 *   http://www.opensource.org/licenses/mit-license.php
 *
 * Copyright 2007, 2008 Chris Wanstrath [ chris@ozmm.org ]
 *
 * Usage:
 *  
 *  jQuery(document).ready(function() {
 *    jQuery('a[rel*=facebox]').facebox() 
 *  })
 *
 *  <a href="#terms" rel="facebox">Terms</a>
 *    Loads the #terms div in the box
 *
 *  <a href="terms.html" rel="facebox">Terms</a>
 *    Loads the terms.html page in the box
 *
 *  <a href="terms.png" rel="facebox">Terms</a>
 *    Loads the terms.png image in the box
 *
 *
 *  You can also use it programmatically:
 * 
 *    jQuery.facebox('some html')
 *
 *  The above will open a facebox with "some html" as the content.
 *    
 *    jQuery.facebox(function($) { 
 *      $.get('blah.html', function(data) { $.facebox(data) })
 *    })
 *
 *  The above will show a loading screen before the passed function is called,
 *  allowing for a better ajaxy experience.
 *
 *  The facebox function can also display an ajax page or image:
 *  
 *    jQuery.facebox({ ajax: 'remote.html' })
 *    jQuery.facebox({ image: 'dude.jpg' })
 *
 *  Want to close the facebox?  Trigger the 'close.facebox' document event:
 *
 *    jQuery(document).trigger('close.facebox')
 *
 *  Facebox also has a bunch of other hooks:
 *
 *    loading.facebox
 *    beforeReveal.facebox
 *    reveal.facebox (aliased as 'afterReveal.facebox')
 *    init.facebox
 *
 *  Simply bind a function to any of these hooks:
 *
 *   $(document).bind('reveal.facebox', function() { ...stuff to do after the facebox and contents are revealed... })
 *
 */
(function(prototype){

  // 据分析 data 可能是个 hash,function,string
  // 生成 Prototype.facebox() 方法
  prototype.facebox = function(data, klass) {
    var facebox = prototype.facebox
    facebox.loading()
    if (data.ajax) facebox.fill_facebox_from_ajax(data.ajax)
    else if (data.image) facebox.fill_facebox_from_image(data.image)
    else if (data.div) facebox.fill_facebox_from_href(data.div)
    else if (Object.isFunction(data)) data.call()
    else prototype.facebox.reveal(data, klass)
  }

  // 给 Prototype.facebox 增加属性
  Object.extend(prototype.facebox, {
    settings: {
      opacity      : 0.5,
      overlay      : true,
      loadingImage : '/facebox/loading.gif',
      closeImage   : '/facebox/closelabel.gif',
      imageTypes   : [ 'png', 'jpg', 'jpeg', 'gif' ],
      faceboxHtml  : '\
    <div id="facebox" class="hide"> \
      <div class="popup"> \
        <table> \
          <tbody> \
            <tr> \
              <td class="tl"/><td class="b"/><td class="tr"/> \
            </tr> \
            <tr> \
              <td class="b"/> \
              <td class="body"> \
                <div class="content"> \
                </div> \
                <div class="footer"> \
                  <a href="#" class="close"> \
                    <img src="/facebox/closelabel.gif" title="close" class="close_image" /> \
                  </a> \
                </div> \
              </td> \
              <td class="b"/> \
            </tr> \
            <tr> \
              <td class="bl"/><td class="b"/><td class="br"/> \
            </tr> \
          </tbody> \
        </table> \
      </div> \
    </div>'
    },
    // 把 驼峰 和 火车 类型 的属性 统一？
    mark_comatible: function(){
      var set = prototype.facebox.settings

      set.loadingImage = set.loading_image || set.loadingImage
      set.closeImage = set.close_image || set.closeImage
      set.imageTypes = set.image_types || set.imageTypes
      set.faceboxHtml = set.facebox_html || set.faceboxHtml
    },
    // 在页面第一次调用 facebox 时，会初始化
    init: function(settings){
      if (prototype.facebox.settings.inited){
        return
      }else{
        prototype.facebox.settings.inited = true
      }
      // 预留 事件回调
      $(document).fire('init.facebox')
      this.mark_comatible()

      var imageTypes = prototype.facebox.settings.imageTypes.join('|')
      prototype.facebox.settings.imageTypesRegexp = new RegExp('\.' + imageTypes + '$', 'i')

      if (settings) Object.extend(prototype.facebox.settings, settings)
      // facebox 是单例
      // 把 facebox 加到 body 的最后边
      new Insertion.Bottom($(document.body), prototype.facebox.settings.faceboxHtml)

      // 不知所以，先注释掉
      //    var preload = [ new Image(), new Image() ]
      //    preload[0].src = prototype.facebox.settings.closeImage
      //    preload[1].src = prototype.facebox.settings.loadingImage
      //
      //    $('#facebox').find('.b:first, .bl, .br, .tl, .tr').each(function() {
      //      preload.push(new Image())
      //      preload.slice(-1).src = $(this).css('background-image').replace(/url\((.+)\)/, '$1')
      //    })

      // 给 关闭 链接 注册事件
      $("facebox").down(".close").observe("click",function(evt){
        prototype.facebox.close()
        evt.stop()
      })
      // 美化 关闭按钮
      $("facebox").down(".close_image").setAttribute('src', prototype.facebox.settings.closeImage)
    },
    //------------
    skip_overlay: function(){
      (prototype.facebox.settings.overlay == false) || (prototype.facebox.settings.opacity === null)
    },
    show_overlay: function(){
      if (this.skip_overlay()) return

      if (!$('facebox_overlay')){
        new Insertion.Bottom($$("body")[0],'<div id="facebox_overlay" class="facebox_hide"></div>')
      }
      var facebox_overlay = $('facebox_overlay')
      facebox_overlay.addClassName("facebox_overlayBG")
      facebox_overlay.setStyle({
        'opacity': prototype.facebox.settings.opacity
      })
      facebox_overlay.observe("click",function(){
        prototype.facebox.close()
      })
    },
    hide_overlay: function(){
      if (this.skip_overlay()) return
      var facebox_overlay = $('facebox_overlay')
      if(facebox_overlay){
        facebox_overlay.removeClassName("facebox_overlayBG")
        facebox_overlay.addClassName("facebox_hide")
        facebox_overlay.remove()
      }
    },
    loading: function() {
      this.init()
      if ($$('#facebox .loading').size() === 1) return
      // 初始化遮盖层？
      this.show_overlay()

      var facebox = $("facebox")
      // 把内容设为空
      facebox.down(".content").update("");
      // 增加 loading 提示
      // <div class="loading"><img src="prototype.facebox.settings.loadingImage"/></div>
      new Insertion.Bottom(facebox.down(".body"),
        Builder.node("div",{
          className: 'loading'
        },Builder.node("img",{
          src:prototype.facebox.settings.loadingImage
        })))

      var pageScroll = document.viewport.getScrollOffsets();
      facebox.setStyle({
        'top': pageScroll.top + (document.viewport.getHeight() / 10) + 'px',
        'left': document.viewport.getWidth() / 2 - (facebox.getWidth() / 2) + 'px'
      });

      $(document).observe('keydown.facebox', function(e) {
        if (e.keyCode == 27) prototype.facebox.close()
        return
      })
      // 预留 回调 方法
      $(document).fire('loading.facebox')
    },

    reveal: function(data, klass) {
      $(document).fire('beforeReveal.facebox')
      var facebox = $("facebox")
      facebox.removeClassName("hide")
      if (klass) facebox.down('.content').addClassName(klass)

      new Insertion.Bottom(facebox.down(".content"), data)
      facebox.down(".loading").remove()
      facebox.setStyle({
        'left':$(document.body).getWidth() / 2 - (facebox.down('table').getWidth() / 2)
      })
      $(document).fire('reveal.facebox')
      $(document).fire('afterReveal.facebox')
    },
    // --------------------------
    // 根据 href 的 类型，来显示不同的内容
    // href formats are:
    //   div: #id
    //   image: "/xx.png|jpg" 或者其他类型的图片
    //   ajax: anything else
    fill_facebox_from_href: function(href, klass) {
      // div
      if (href.match(/#/)) {
        var url    = window.location.href.split('#')[0]
        var target = href.replace(url,'')
        target = target.replace("#","")
        prototype.facebox.reveal($(target).clone(true), klass)

      // image
      } else if (href.match(prototype.facebox.settings.imageTypesRegexp)) {
        this.fill_facebox_from_image(href, klass)
      // ajax
      } else {
        this.fill_facebox_from_ajax(href, klass)
      }
    },

    fill_facebox_from_image: function(href, klass) {
      var image = new Image()
      image.onload = function() {
        prototype.facebox.reveal('<div class="image"><img src="' + image.src + '" /></div>', klass)
      }
      image.src = href
    },

    fill_facebox_from_ajax: function(href, klass) {
      new Ajax.Request(href,{
        method: 'get',
        onSuccess: function(transport){
          prototype.facebox.reveal(transport.responseText, klass)
        }
      })
    },
    // ---------------------------

    close: function() {
      var facebox = $("facebox")
      if(!facebox) return
      var content = facebox.down(".content")
      content.classNames().each(function(klass){
        content.removeClassName(klass)
      })
      content.addClassName("content")

      this.hide_overlay()
      var loading = facebox.down(".loading")
      if (loading) loading.remove()

      facebox.addClassName("hide")
    }
  });

  // 给 $(id) 对象 增加 facebox 方法
  Element.addMethods({
    facebox: function(ele,settings){
      prototype.facebox.init(settings)

      ele.observe("click",function(evt){
        prototype.facebox.loading()

        // support for rel="facebox.inline_popup" syntax, to add a class
        // also supports deprecated "facebox[.inline_popup]" syntax
        var klass = ele.rel.match(/facebox\[?\.(\w+)\]?/)
        if (klass) klass = klass[1]

        prototype.facebox.fill_facebox_from_href(ele.href, klass)
        evt.stop()
      })
    }
  });

  pie.load(function() {
    $$('a[rel*=facebox]').each(function(a){
      a.facebox()
    })
  })
})(Prototype);