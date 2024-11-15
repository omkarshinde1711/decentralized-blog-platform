module blogPlatform::Blog {
    use std::string::String;
    use aptos_framework::timestamp;
    use aptos_framework::signer;

    /// Struct for storing blog post information
    struct Post has store, key {
        author: address,
        content: String,
        timestamp: u64,
        likes: u64
    }

    /// Resource to track all posts by a user
    struct UserPosts has key {
        post_count: u64
    }

    /// Error codes
    const E_POST_DOESNT_EXIST: u64 = 1;
    const E_NOT_AUTHORIZED: u64 = 2;

    /// Create a new blog post
    public entry fun create_post(
        author: &signer,
        content: String
    ) acquires UserPosts {
        let author_addr = signer::address_of(author);
        
        // Initialize UserPosts if this is the user's first post
        if (!exists<UserPosts>(author_addr)) {
            move_to(author, UserPosts { post_count: 0 });
        };
        
        let user_posts = borrow_global_mut<UserPosts>(author_addr);
        user_posts.post_count = user_posts.post_count + 1;

        // Create and store the new post
        let post = Post {
            author: author_addr,
            content,
            timestamp: timestamp::now_seconds(),
            likes: 0
        };
        move_to(author, post);
    }

    /// Like or unlike a post
    public entry fun toggle_like(
        _user: &signer, // Prefix with '_' to indicate it's an unused parameter
        post_author: address
    ) acquires Post {
        assert!(exists<Post>(post_author), E_POST_DOESNT_EXIST);
        let post = borrow_global_mut<Post>(post_author);
        post.likes = post.likes + 1;
    }
}