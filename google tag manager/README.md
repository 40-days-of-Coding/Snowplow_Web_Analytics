# Install Google Tag Manager for web pages

Google Tag Manager is a tag management system that allows you to update tags on your website quickly and easily. Tag Manager installation for web requires a small piece of code that you add to your web pages. This code enables Tag Manager to fire tags by inserting tags into web pages.

### Custom web installations
In rare cases (e.g. when creating a new template for a content management system or ecommerce template), you may wish to code a custom gtm.js tag. Add the following code so that it is as close to the opening <head> tag as possible on every page of your website. Replace GTM-XXXXXX with your container ID:

```
<!-- Google Tag Manager -->
<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
})(window,document,'script','dataLayer','GTM-XXXXXX');</script>
<!-- End Google Tag Manager -->
```


### Next, add this code immediately after the opening <body> element on every page of your website. Replace GTM-XXXXXX with your container ID:

```
<!-- Google Tag Manager (noscript) -->
<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-XXXXXX"
height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<!-- End Google Tag Manager (noscript) -->
```
