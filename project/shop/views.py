import os
import socket

from cart.forms import CartAddProductForm
from django.conf import settings
from django.http import JsonResponse
from django.shortcuts import get_object_or_404, render

from .models import Category, Product
from .recommender import Recommender


def test_host(request):
    headers = {key: value for key, value in request.headers.items()}  # Get all headers
    data = {
        "host": request.get_host(),  # Should include the port
        "hostdata": "host",
        "headers": headers,  # Include all headers for debugging
    }
    return JsonResponse(data)


def list_media_images(request):
    media_path = settings.MEDIA_ROOT
    images = []

    # Walk through the MEDIA_ROOT directory and collect all image file paths
    for root, dirs, files in os.walk(media_path):
        for file in files:
            if file.endswith((".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp")):
                relative_path = os.path.relpath(os.path.join(root, file), media_path)
                image_url = f"{settings.MEDIA_URL}{relative_path}"
                images.append(image_url)

    return JsonResponse({"images": images})


def product_list(request, category_slug=None):
    category = None
    categories = Category.objects.all()
    products = Product.objects.filter(available=True)
    if category_slug:
        category = get_object_or_404(Category, slug=category_slug)
        products = products.filter(category=category)
    return render(
        request,
        "shop/product/list.html",
        {"category": category, "categories": categories, "products": products},
    )


def product_detail(request, id, slug):
    product = get_object_or_404(Product, id=id, slug=slug, available=True)
    cart_product_form = CartAddProductForm()
    r = Recommender()
    recommended_products = r.suggest_products_for([product], 4)
    return render(
        request,
        "shop/product/detail.html",
        {
            "product": product,
            "cart_product_form": cart_product_form,
            "recommended_products": recommended_products,
        },
    )
